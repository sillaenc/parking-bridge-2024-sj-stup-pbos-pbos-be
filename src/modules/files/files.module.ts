import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { FilesController } from './files.controller';
import { FilesService } from './files.service';
import { FilesStubController } from './files.stub.controller';
import { ParkingZonesController } from './parking-zones.controller';

@Module({
  imports: [PrismaModule],
  controllers: [FilesController, FilesStubController, ParkingZonesController],
  providers: [FilesService],
})
export class FilesModule {}
