import { Injectable } from '@nestjs/common';
import { execFile } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateCameraDto } from './dto/create-camera.dto';
import { RtspImageDto } from './dto/rtsp-image.dto';
import { ConfigService } from '@nestjs/config';

const CAPTURE_DIR = path.join(process.cwd(), 'camera', 'captures');

@Injectable()
export class RtspService {
  private readonly batchSize: number;
  private readonly maxRetries: number;

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {
    const n = Number(this.config.get<string>('RTSP_BATCH_SIZE') ?? '20');
    this.batchSize = Number.isFinite(n) && n > 0 ? Math.floor(n) : 20;
    const retry = Number(this.config.get<string>('RTSP_RETRY_ATTEMPTS') ?? '2');
    this.maxRetries = Number.isFinite(retry) && retry >= 0 ? Math.floor(retry) : 2;
  }

  async listCameras() {
    return this.prisma.rtspCapture.findMany({
      orderBy: { id: 'asc' },
    });
  }

  async createCamera(dto: CreateCameraDto) {
    return this.prisma.rtspCapture.create({
      data: {
        tag: dto.tag,
        rtspAddress: dto.rtspAddress,
        lastImagePath: dto.lastImagePath,
      },
    });
  }

  async updateCamera(tag: string, dto: CreateCameraDto) {
    return this.prisma.rtspCapture.update({
      where: { tag },
      data: {
        rtspAddress: dto.rtspAddress,
        lastImagePath: dto.lastImagePath,
      },
    });
  }

  async deleteCamera(tag: string) {
    await this.prisma.rtspCapture.delete({
      where: { tag },
    });
    return { deleted: true };
  }

  async getByTag(tag: string) {
    return this.prisma.rtspCapture.findUnique({
      where: { tag },
    });
  }

  async distinctRtspAddresses() {
    return this.prisma.$queryRaw<
      { rtsp_address: string }[]
    >`SELECT DISTINCT rtsp_address FROM "rtsp_capture" WHERE rtsp_address IS NOT NULL AND rtsp_address <> ''`;
  }

  async stats() {
    const rows = await this.prisma.$queryRaw<{ unique_cameras: bigint; total_tags: bigint }[]>`
      SELECT COUNT(DISTINCT rtsp_address) AS unique_cameras, COUNT(*) AS total_tags
      FROM "rtsp_capture"
    `;
    if (rows.length === 0) return { unique_cameras: 0, total_tags: 0 };
    return {
      unique_cameras: Number(rows[0].unique_cameras),
      total_tags: Number(rows[0].total_tags),
    };
  }

  async getImagePath(tag: string) {
    const cam = await this.getByTag(tag);
    if (cam?.lastImagePath) return cam.lastImagePath;
    return path.join(CAPTURE_DIR, `${tag}.jpg`);
  }

  async readImage(tag: string) {
    const imagePath = await this.getImagePath(tag);
    if (!fs.existsSync(imagePath)) return null;
    const buffer = fs.readFileSync(imagePath);
    return { buffer, imagePath };
  }

  private ensureDir(dir: string) {
    fs.mkdirSync(dir, { recursive: true });
  }

  private isFreshCapture(targetPath: string, startedAt: number) {
    try {
      const stat = fs.statSync(targetPath);
      return stat.size > 0 && stat.mtimeMs >= startedAt - 500; // 허용 오차 0.5s
    } catch {
      return false;
    }
  }

  private rtspAddressToPath(rtspAddress: string) {
    try {
      const uri = new URL(rtspAddress);
      const host = uri.hostname.replaceAll('.', '_').replaceAll('-', '_').toLowerCase();
      const port = uri.port ? `_${uri.port}` : '_554';
      const channel = uri.searchParams.get('channel');
      const chSuffix = channel ? `_ch${channel.replace(/[^a-zA-Z0-9]/g, '_')}` : '';
      return path.join(CAPTURE_DIR, `cam_${host}${port}${chSuffix}.jpg`);
    } catch {
      const hash = Math.abs(
        Array.from(rtspAddress).reduce((hash, ch) => (hash * 31 + ch.charCodeAt(0)) | 0, 0),
      );
      return path.join(CAPTURE_DIR, `cam_fallback_${hash}.jpg`);
    }
  }

  async createPlaceholderForAddress(rtspAddress: string, tag?: string) {
    const targetPath = this.rtspAddressToPath(rtspAddress);
    this.ensureDir(path.dirname(targetPath));
    if (!fs.existsSync(targetPath)) {
      fs.writeFileSync(targetPath, Buffer.from('RTSP_PLACEHOLDER'));
    }
    await this.prisma.rtspCapture.updateMany({
      where: tag ? { tag } : { rtspAddress },
      data: { lastImagePath: targetPath },
    });
    return { ok: true, path: targetPath };
  }

  async captureWithFfmpeg(rtspAddress: string, targetPath: string) {
    this.ensureDir(path.dirname(targetPath));
    const timeoutMs = Number(
      this.config.get<string>('FFMPEG_TIMEOUT_MS') ?? this.config.get<string>('FFMPEG_TIMEOUT') ?? '30000',
    );
    const startedAt = Date.now();
    return new Promise<{ ok: boolean; status?: number; error?: string }>((resolve) => {
      const args = [
        '-y',
        '-rtsp_transport',
        'tcp',
        '-i',
        rtspAddress,
        '-vframes',
        '1',
        '-q:v',
        '2',
        targetPath,
      ];
      execFile(
        'ffmpeg',
        args,
        { timeout: Number.isFinite(timeoutMs) ? timeoutMs : 30000 },
        (error, _stdout, stderr) => {
          const produced = this.isFreshCapture(targetPath, startedAt);
          if (produced) {
            resolve({ ok: true });
            return;
          }
          if (error) {
            // stderr에서 RTSP 응답 코드 추출 시도
            const match = `${stderr}`.match(/(40\d|50\d)/);
            const code = match ? Number(match[1]) : undefined;
            resolve({ ok: false, status: code, error: error.message });
            return;
          }
          resolve({ ok: false, error: 'ffmpeg produced no output' });
        },
      );
    });
  }

  async saveImage(tag: string, dto: RtspImageDto) {
    if (!dto.image_base64 && !dto.image_path) {
      throw new Error('image_base64 or image_path required');
    }
    const targetPath = dto.image_path
      ? path.isAbsolute(dto.image_path)
        ? dto.image_path
        : path.join(CAPTURE_DIR, dto.image_path)
      : path.join(CAPTURE_DIR, `${tag}.jpg`);

    this.ensureDir(path.dirname(targetPath));

    if (dto.image_base64) {
      const buffer = Buffer.from(dto.image_base64, 'base64');
      fs.writeFileSync(targetPath, buffer);
    } else if (dto.image_path) {
      if (!fs.existsSync(targetPath)) {
        throw new Error('image_path not found on disk');
      }
    }

    await this.prisma.rtspCapture.updateMany({
      where: { tag },
      data: { lastImagePath: targetPath },
    });

    return { image_path: targetPath };
  }

  async captureCamera(tag: string) {
    const cam = await this.getByTag(tag);
    if (!cam?.rtspAddress) {
      throw new Error('RTSP address not found');
    }
    const targetPath = this.rtspAddressToPath(cam.rtspAddress);
    const res = await this.captureWithFfmpeg(cam.rtspAddress, targetPath);
    if (!res.ok) throw new Error(res.error || 'ffmpeg capture failed');

    await this.prisma.rtspCapture.update({
      where: { tag },
      data: { lastImagePath: targetPath },
    });
    return { success: true, image_path: targetPath };
  }

  private async captureOne(cam: { tag: string; rtspAddress: string }) {
    const targetPath = this.rtspAddressToPath(cam.rtspAddress);
    const res = await this.captureWithFfmpeg(cam.rtspAddress, targetPath);
    if (res.ok) {
      await this.prisma.rtspCapture.updateMany({
        where: { rtspAddress: cam.rtspAddress },
        data: { lastImagePath: targetPath },
      });
      return { tag: cam.tag, success: true, image_path: targetPath };
    }
    return {
      tag: cam.tag,
      success: false,
      error: res.error || 'capture failed',
      status: res.status,
    };
  }

  private async captureChunkWithRetry(cameras: { tag: string; rtspAddress: string }[]) {
    let results = await Promise.all(cameras.map((cam) => this.captureOne(cam)));
    let failed = results.filter((r) => !r.success);

    let attempt = 0;
    while (failed.length && attempt < this.maxRetries) {
      attempt++;
      const retryTargets = cameras.filter((cam) => failed.some((f) => f.tag === cam.tag));
      const retryResults = await Promise.all(retryTargets.map((cam) => this.captureOne(cam)));
      // 최신 결과로 교체
      results = results.map((r) => {
        const newer = retryResults.find((nr) => nr.tag === r.tag);
        return newer ?? r;
      });
      failed = results.filter((r) => !r.success);
    }

    return results;
  }

  async triggerAllCaptures() {
    // 같은 rtspAddress 중복 제거 (같은 채널 중복 연결 방지)
    const allCameras = await this.listCameras();
    const seen = new Map<string, typeof allCameras[number]>();
    for (const cam of allCameras) {
      if (!cam.rtspAddress) continue;
      if (!seen.has(cam.rtspAddress)) seen.set(cam.rtspAddress, cam);
    }
    const cameras = Array.from(seen.values());
    const results: { tag: string; success: boolean; image_path?: string; error?: string }[] = [];
    for (let i = 0; i < cameras.length; i += this.batchSize) {
      const chunk = cameras.slice(i, i + this.batchSize);
      const chunkResults = await this.captureChunkWithRetry(chunk);
      results.push(...chunkResults);
    }
    const successCount = results.filter((r) => r.success).length;
    return {
      success: successCount === cameras.length,
      total: cameras.length,
      successful: successCount,
      failed: cameras.length - successCount,
      results,
    };
  }
}
