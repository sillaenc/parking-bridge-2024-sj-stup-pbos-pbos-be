import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { DisplayController } from './display.controller';
import { DisplayService } from './display.service';

@Module({
  imports: [PrismaModule],
  controllers: [DisplayController],
  providers: [DisplayService],
})
export class DisplayModule {}
