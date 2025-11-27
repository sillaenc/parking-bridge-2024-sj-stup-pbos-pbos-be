import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { ElectricSignsController } from './electric-signs.controller';
import { ElectricSignsService } from './electric-signs.service';

@Module({
  imports: [PrismaModule],
  controllers: [ElectricSignsController],
  providers: [ElectricSignsService],
})
export class ElectricSignsModule {}
