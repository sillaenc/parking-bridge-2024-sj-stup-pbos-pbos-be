import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { StatsController } from './stats.controller';
import { StatsService } from './stats.service';
import { StatsCleanupService } from './stats.cleanup.service';
import { StatsBackupService } from './stats.backup.service';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [PrismaModule, ConfigModule],
  controllers: [StatsController],
  providers: [StatsService, StatsCleanupService, StatsBackupService],
})
export class StatsModule {}
