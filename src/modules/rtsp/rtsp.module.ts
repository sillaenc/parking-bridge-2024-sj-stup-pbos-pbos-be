import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { RtspController } from './rtsp.controller';
import { RtspService } from './rtsp.service';
import { RtspStubController } from './rtsp.stub.controller';
import { RtspBootstrap } from './rtsp.bootstrap';
import { RtspSchedulerService } from './rtsp.scheduler';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [PrismaModule, ConfigModule],
  controllers: [RtspController, RtspStubController],
  providers: [RtspService, RtspBootstrap, RtspSchedulerService],
})
export class RtspModule {}
