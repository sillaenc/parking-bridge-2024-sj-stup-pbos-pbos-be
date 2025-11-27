import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import * as fs from 'fs/promises';
import * as path from 'path';

type LotJson = {
  tag: string;
  lot_type: number;
  point?: string;
  asset?: string;
  floor?: string;
};

@Injectable()
export class FirstSettingService implements OnModuleInit {
  private readonly logger = new Logger(FirstSettingService.name);

  constructor(private readonly prisma: PrismaService) {}

  async onModuleInit() {
    try {
      await this.seedFromLocalFiles();
    } catch (e) {
      this.logger.error('초기 데이터 세팅 실패', e as any);
    }
  }

  private deriveFloorFromFileName(fileName: string) {
    const base = fileName.replace('.json', '');
    let floor = '';
    if (base.startsWith('F')) floor += 'F';
    else if (base.startsWith('B')) floor += 'B';
    else if (base.startsWith('ALL')) floor += 'ALL';
    const num = base.match(/\d+/)?.[0];
    if (num) floor += num;
    return floor || base;
  }

  private async readJsonFiles(dir: string) {
    try {
      const entries = await fs.readdir(dir);
      const files = entries.filter((f) => f.toLowerCase().endsWith('.json'));
      const results: { name: string; data: any }[] = [];
      for (const file of files.sort()) {
        const full = path.join(dir, file);
        const content = await fs.readFile(full, 'utf8');
        results.push({ name: file, data: JSON.parse(content) });
      }
      return results;
    } catch (e) {
      this.logger.warn(`폴더를 읽을 수 없습니다: ${dir} (${(e as Error)?.message})`);
      return [];
    }
  }

  private buildLotPayload(entries: { data: any }[]) {
    const payload: LotJson[] = [];
    for (const entry of entries) {
      const lots = entry.data?.tb_lots;
      if (!lots || typeof lots !== 'object') continue;
      for (const item of Object.values(lots)) {
        const lot = item as any;
        payload.push({
          tag: lot.tag,
          lot_type: lot.lot_type,
          point: lot.point,
          asset: lot.asset,
          floor: lot.floor,
        });
      }
    }
    return payload;
  }

  private async seedParkingZonesIfNeeded(jsonEntries: { name: string }[]) {
    const zoneCount = await this.prisma.parkingZone.count();
    if (zoneCount > 0) return;

    const zones = jsonEntries.map((f) => ({
      parkingName: f.name,
      fileAddress: path.join('json_folder', f.name),
      floor: this.deriveFloorFromFileName(f.name),
    }));

    if (zones.length) {
      await this.prisma.parkingZone.createMany({ data: zones, skipDuplicates: true });
      this.logger.log(`ParkingZone 초기화 완료 (${zones.length}건)`);
    }
  }

  private async upsertLots(jsonEntries: { data: any }[]) {
    const lots = this.buildLotPayload(jsonEntries);
    if (lots.length === 0) return;

    for (const l of lots) {
      const tag = l.tag?.slice(0, 50) ?? null;
      if (!tag) continue;
      await this.prisma.lot.upsert({
        where: { tag },
        create: {
          tag,
          lotTypeId: l.lot_type ?? null,
          point: l.point ?? null,
          asset: l.asset ?? null,
          floor: l.floor ?? null,
          parked: true,
          isUsed: false,
        },
        update: {
          lotTypeId: l.lot_type ?? null,
          point: l.point ?? null,
          asset: l.asset ?? null,
          floor: l.floor ?? null,
        },
      });
    }
    this.logger.log(`tb_lots upsert 완료 (${lots.length}건)`);
  }

  private async upsertDisplay(displayEntries: { data: any }[]) {
    const lots = this.buildLotPayload(displayEntries);
    if (lots.length === 0) return;

    for (const l of lots) {
      const tag = l.tag?.slice(0, 50) ?? null;
      if (!tag) continue;
      await this.prisma.display.upsert({
        where: { tag },
        create: {
          tag,
          lotTypeId: l.lot_type ?? null,
          point: l.point ?? null,
          asset: l.asset ?? null,
          floor: l.floor ?? null,
        },
        update: {
          lotTypeId: l.lot_type ?? null,
          point: l.point ?? null,
          asset: l.asset ?? null,
          floor: l.floor ?? null,
        },
      });
    }
    this.logger.log(`display upsert 완료 (${lots.length}건)`);
  }

  private makeRtspImagePath(rtspAddress: string) {
    const fallbackHash = () =>
      Math.abs(
        Array.from(rtspAddress).reduce((hash, ch) => (hash * 31 + ch.charCodeAt(0)) | 0, 0),
      );
    try {
      const uri = new URL(rtspAddress);
      const host = uri.hostname.replaceAll('.', '_').replaceAll('-', '_');
      const port = uri.port ? `_${uri.port}` : '';
      return path.join('camera', 'captures', `cam_${host}${port}.jpg`);
    } catch {
      return path.join('camera', 'captures', `cam_${fallbackHash()}.jpg`);
    }
  }

  private async seedRtspIfNeeded(rtspEntries: { data: any }[]) {
    const rtspCount = await this.prisma.rtspCapture.count();
    if (rtspCount > 0) return;

    const records: { tag: string; rtspAddress: string; lastImagePath?: string }[] = [];
    for (const entry of rtspEntries) {
      const rtsp = entry.data?.rtsp;
      if (!rtsp || typeof rtsp !== 'object') continue;
      for (const item of Object.values(rtsp) as any[]) {
        const tag = item.tag as string;
        const address = item.rtsp_address as string;
        records.push({
          tag,
          rtspAddress: address,
          lastImagePath: this.makeRtspImagePath(address),
        });
      }
    }

    if (records.length) {
      await this.prisma.rtspCapture.createMany({ data: records, skipDuplicates: true });
      this.logger.log(`rtsp_capture 초기화 완료 (${records.length}건)`);
    }
  }

  private async seedFromLocalFiles() {
    const lotsJson = await this.readJsonFiles(path.join(process.cwd(), 'json_folder'));
    const displayJson = await this.readJsonFiles(path.join(process.cwd(), 'display'));
    const rtspJson = await this.readJsonFiles(path.join(process.cwd(), 'rtsp'));

    await this.seedParkingZonesIfNeeded(lotsJson);
    await this.upsertLots(lotsJson);
    await this.upsertDisplay(displayJson);
    await this.seedRtspIfNeeded(rtspJson);
  }
}
