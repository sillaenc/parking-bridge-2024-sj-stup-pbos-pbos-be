import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { EngineProcessorService } from './engine-processor.service';

@Injectable()
export class EngineSchedulerService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(EngineSchedulerService.name);
  private isProcessing = false;
  private timer?: NodeJS.Timer;

  constructor(private readonly engineProcessor: EngineProcessorService) {}

  async handleInterval() {
    if (this.isProcessing) return;
    this.isProcessing = true;
    try {
      await this.engineProcessor.processCycle();
    } catch (e) {
      this.logger.error('Periodic engine task failed', e as any);
    } finally {
      this.isProcessing = false;
    }
  }

  onModuleInit() {
    this.timer = setInterval(() => this.handleInterval(), 2000);
  }

  onModuleDestroy() {
    if (this.timer) clearInterval(this.timer);
  }
}
