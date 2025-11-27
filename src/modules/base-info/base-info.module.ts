import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { BaseInfoController } from './base-info.controller';
import { BaseInfoService } from './base-info.service';
import { BaseInfoLegacyController } from './base-info.legacy.controller';

@Module({
  imports: [PrismaModule],
  controllers: [BaseInfoController, BaseInfoLegacyController],
  providers: [BaseInfoService],
  exports: [BaseInfoService],
})
export class BaseInfoModule {}
