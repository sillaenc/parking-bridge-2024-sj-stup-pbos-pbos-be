import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { FilesController } from './files.controller';
import { FilesService } from './files.service';
import { FilesStubController } from './files.stub.controller';

@Module({
  imports: [PrismaModule],
  controllers: [FilesController, FilesStubController],
  providers: [FilesService],
})
export class FilesModule {}
