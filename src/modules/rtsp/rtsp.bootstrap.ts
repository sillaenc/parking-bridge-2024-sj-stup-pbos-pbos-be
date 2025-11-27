import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { RtspService } from './rtsp.service';

@Injectable()
export class RtspBootstrap implements OnModuleInit {
  private readonly logger = new Logger(RtspBootstrap.name);

  constructor(private readonly rtspService: RtspService) {}

  async onModuleInit() {
    try {
      const cameras = await this.rtspService.listCameras();
      if (!cameras.length) return;

      // rtsp_address 기준으로 중복 제거
      const unique = new Map<string, string>(); // addr -> tag
      for (const cam of cameras) {
        if (!cam.rtspAddress) continue;
        if (!unique.has(cam.rtspAddress)) unique.set(cam.rtspAddress, cam.tag);
      }

      let successCount = 0;
      const failed: { tag: string; reason: string }[] = [];

      for (const [addr, tag] of unique) {
        const res = await this.rtspService.createPlaceholderForAddress(addr, tag);
        if (res.ok) successCount++;
        else failed.push({ tag, reason: res.error ?? '알 수 없는 오류' });
      }

      this.logger.log(
        `RTSP 플레이스홀더 생성 완료: ${successCount}/${unique.size}개 성공, 실패 ${failed.length}개`,
      );
      if (failed.length) {
        const detail = failed.map((f) => `${f.tag}(${f.reason})`).join(', ');
        this.logger.warn(`실패 목록: ${detail}`);
      }
    } catch (e) {
      this.logger.warn(`RTSP placeholder init failed: ${e}`);
    }
  }
}
