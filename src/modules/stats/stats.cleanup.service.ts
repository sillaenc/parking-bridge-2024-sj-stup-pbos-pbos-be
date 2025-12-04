import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SchedulerRegistry } from '@nestjs/schedule';
import { CronJob } from 'cron';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class StatsCleanupService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(StatsCleanupService.name);
  private tables: string[] = [];
  private cronExpr = '0 2 0 * * *'; // 기본값: 매일 00:02
  private jobName = 'stats-truncate-job';

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly scheduler: SchedulerRegistry,
  ) {}

  onModuleInit() {
    const tablesEnv = this.config.get<string>('STATS_TRUNCATE_TABLES');
    this.tables = tablesEnv
      ? tablesEnv
          .split(',')
          .map((t) => t.trim())
          .filter(Boolean)
      : ['rawdata', 'tb_lot_status'];

    this.cronExpr = this.config.get<string>('STATS_TRUNCATE_CRON') || '0 2 0 * * *';

    const job = new CronJob(this.cronExpr, () => this.truncateTables());
    this.scheduler.addCronJob(this.jobName, job);
    job.start();
    this.logger.log(
      `Stats cleanup scheduled: cron="${this.cronExpr}", tables=[${this.tables.join(', ')}]`,
    );
  }

  onModuleDestroy() {
    try {
      this.scheduler.deleteCronJob(this.jobName);
    } catch {
      /* ignore */
    }
  }

  private async truncateTables() {
    if (this.tables.length === 0) return;
    try {
      const sql = `TRUNCATE TABLE ${this.tables.join(', ')} RESTART IDENTITY`;
      await this.prisma.$executeRawUnsafe(sql);
      this.logger.log(`Truncated tables: ${this.tables.join(', ')}`);
    } catch (e) {
      this.logger.error(`Failed to truncate tables: ${this.tables.join(', ')}`, e as any);
    }
  }
}
