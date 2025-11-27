import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { BillboardController } from './billboard.controller';
import { BillboardService } from './billboard.service';

@Module({
  imports: [PrismaModule],
  controllers: [BillboardController],
  providers: [BillboardService],
})
export class BillboardModule {}
