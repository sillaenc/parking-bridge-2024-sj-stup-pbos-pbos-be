import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SchedulerRegistry } from '@nestjs/schedule';
import { CronJob } from 'cron';
import * as fs from 'fs/promises';
import * as path from 'path';
import { execFile } from 'child_process';

@Injectable()
export class StatsBackupService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(StatsBackupService.name);
  private cronExpr = '0 30 2 * * *'; // 매일 02:30
  private backupDir = 'db_backups';
  private keepCount = 7;
  private jobName = 'stats-backup-job';

  constructor(
    private readonly config: ConfigService,
    private readonly scheduler: SchedulerRegistry,
  ) {}

  onModuleInit() {
    this.cronExpr = this.config.get<string>('STATS_BACKUP_CRON') || this.cronExpr;
    this.backupDir = this.config.get<string>('STATS_BACKUP_DIR') || this.backupDir;
    this.keepCount = Number(this.config.get<string>('STATS_BACKUP_KEEP') || this.keepCount);
    const job = new CronJob(this.cronExpr, () => this.runBackup());
    this.scheduler.addCronJob(this.jobName, job);
    job.start();
    this.logger.log(
      `Stats DB backup scheduled: cron="${this.cronExpr}", dir=${this.backupDir}, keep=${this.keepCount}`,
    );
  }

  onModuleDestroy() {
    try {
      this.scheduler.deleteCronJob(this.jobName);
    } catch {
      /* ignore */
    }
  }

  private async runBackup() {
    const databaseUrl = this.config.get<string>('DATABASE_URL');
    if (!databaseUrl) {
      this.logger.warn('DATABASE_URL is not set; skip backup');
      return;
    }
    try {
      await fs.mkdir(this.backupDir, { recursive: true });
      const ts = new Date()
        .toISOString()
        .replace(/[:.]/g, '-')
        .replace('T', '_')
        .replace('Z', '');
      const fileName = `backup_${ts}.sql`;
      const filePath = path.join(this.backupDir, fileName);

      await new Promise<void>((resolve, reject) => {
        execFile(
          'pg_dump',
          ['-f', filePath, databaseUrl],
          { timeout: 5 * 60 * 1000 }, // 5분 타임아웃
          (err, stdout, stderr) => {
            if (stdout) this.logger.verbose(stdout.trim());
            if (stderr) this.logger.debug(stderr.trim());
            if (err) return reject(err);
            return resolve();
          },
        );
      });

      await this.pruneOldBackups();
      this.logger.log(`DB backup completed: ${filePath}`);
    } catch (e) {
      this.logger.error('DB backup failed', e as any);
    }
  }

  private async pruneOldBackups() {
    if (this.keepCount <= 0) return;
    const files = await fs.readdir(this.backupDir).catch(() => []);
    const backups = files
      .filter((f) => f.startsWith('backup_') && f.endsWith('.sql'))
      .map((f) => ({ name: f, time: fs.stat(path.join(this.backupDir, f)) }));
    const stats = await Promise.all(backups.map(async (b) => ({ name: b.name, mtime: (await b.time).mtimeMs })));
    stats.sort((a, b) => b.mtime - a.mtime);
    const toDelete = stats.slice(this.keepCount);
    for (const file of toDelete) {
      try {
        await fs.unlink(path.join(this.backupDir, file.name));
        this.logger.log(`Pruned old backup: ${file.name}`);
      } catch (e) {
        this.logger.warn(`Failed to delete old backup ${file.name}: ${(e as any)?.message}`);
      }
    }
  }
}
