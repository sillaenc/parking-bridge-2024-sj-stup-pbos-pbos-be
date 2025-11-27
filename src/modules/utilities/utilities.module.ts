import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { UtilitiesController } from './utilities.controller';

@Module({
  imports: [PrismaModule],
  controllers: [UtilitiesController],
})
export class UtilitiesModule {}
