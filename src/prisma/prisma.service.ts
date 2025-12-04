import { Injectable, OnModuleDestroy, OnModuleInit, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  async onModuleInit() {
    await this.$connect();
    // 세션 타임존을 KST로 고정 (DB/PGTZ 설정을 보완)
    try {
      await this.$executeRawUnsafe(`SET TIME ZONE 'Asia/Seoul'`);
      this.logger.log('Session time zone set to Asia/Seoul');
    } catch (e) {
      this.logger.warn(`Failed to set time zone: ${(e as any)?.message ?? e}`);
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
