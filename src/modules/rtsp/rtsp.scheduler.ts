import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { RtspService } from './rtsp.service';

@Injectable()
export class RtspSchedulerService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RtspSchedulerService.name);
  private stop = false;
  private running = false;
  private readonly cycleDelayMs: number;

  constructor(private readonly rtspService: RtspService) {
    // 사이클 간 대기시간 (pbos_be_v2 기준 2분) - 배치 간 대기는 없음
    const ms = Number(
      process.env.RTSP_CYCLE_DELAY_MS ??
        process.env.RTSP_BATCH_DELAY_MS ?? // 구버전 호환
        process.env.RTSP_DELAY_MS ??
        120000,
    );
    this.cycleDelayMs = Number.isFinite(ms) && ms >= 0 ? ms : 120000;
  }

  onModuleInit() {
    // 첫 사이클 시작
    this.loop();
  }

  onModuleDestroy() {
    this.stop = true;
  }

  private async loop() {
    if (this.running || this.stop) return;
    this.running = true;
      const result = await this.tick();
      this.running = false;
      if (!this.stop) {
        this.logger.log(
          `RTSP 캡처 배치 완료: 총 ${result.total}건, 성공 ${result.successful}, 실패 ${result.failed}`,
        );
        if (!result.failed) {
          this.logger.log(`RTSP 캡처 성공: ${result.successful}/${result.total}개`);
        }
      if (result.failed) {
        const failed = result.results
          .filter((r) => !r.success)
          .map((r) => `${r.tag}${r.status ? `(${r.status})` : ''}`)
          .join(', ');
        this.logger.warn(`RTSP 캡처 실패 태그: ${failed}`);
      }
      // 한 사이클 결과 로그 후 대기 시간 적용
      setTimeout(() => this.loop(), this.cycleDelayMs);
    }
  }

  private async tick() {
    try {
      const result = await this.rtspService.triggerAllCaptures();
      return result;
    } catch (e: any) {
      this.logger.error(`RTSP 캡처 배치 실패: ${e?.message || e}`);
      return { total: 0, successful: 0, failed: 0, results: [] };
    }
  }
}
