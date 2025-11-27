import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { CameraParkingController } from './camera-parking.controller';
import { CameraParkingService } from './camera-parking.service';

@Module({
  imports: [PrismaModule],
  controllers: [CameraParkingController],
  providers: [CameraParkingService],
})
export class CameraParkingModule {}
