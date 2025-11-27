import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { CentralController } from './central.controller';
import { CentralService } from './central.service';

@Module({
  imports: [PrismaModule],
  controllers: [CentralController],
  providers: [CentralService],
})
export class CentralModule {}
