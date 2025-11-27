import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SystemService {
  constructor(private readonly prisma: PrismaService) {}

  async healthCheck() {
    // 간단한 DB ping으로 연결 상태 확인
    await this.prisma.$queryRaw`SELECT 1`;
    return { status: 'ok' };
  }
}
