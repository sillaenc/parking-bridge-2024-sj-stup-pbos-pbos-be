import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { EngineController } from './engine.controller';
import { EngineService } from './engine.service';
import { EngineProcessorService } from './engine-processor.service';
import { EngineSchedulerService } from './engine-scheduler.service';

@Module({
  imports: [PrismaModule],
  controllers: [EngineController],
  providers: [EngineService, EngineProcessorService, EngineSchedulerService],
})
export class EngineModule {}
