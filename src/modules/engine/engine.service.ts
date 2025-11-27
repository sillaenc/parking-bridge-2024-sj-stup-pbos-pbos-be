import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class EngineService {
  constructor(private readonly prisma: PrismaService) {}

  async processData() {
    // TODO: 실제 엔진 데이터 처리 로직 연계
    const processed = await this.prisma.processedDb.count();
    return { processed };
  }

  async status() {
    const totalLots = await this.prisma.lot.count({ where: { floor: { not: 'ALL' } } });
    const usedLots = await this.prisma.lot.count({
      where: { floor: { not: 'ALL' }, isUsed: true },
    });
    return { totalLots, usedLots, available: totalLots - usedLots };
  }

  async errors() {
    // 엔진 오류 테이블이 없으므로 기본 빈 배열 반환
    return [];
  }

  async statistics() {
    const perLotType = await this.prisma.$queryRaw<
      { lot_type: number | null; total: bigint; used: bigint }[]
    >`
      SELECT lot_type, COUNT(*) AS total,
             SUM(CASE WHEN "isUsed" = true THEN 1 ELSE 0 END) AS used
      FROM "tb_lots"
      WHERE floor IS NOT NULL AND floor <> 'ALL'
      GROUP BY lot_type
      ORDER BY lot_type
    `;
    return { perLotType };
  }
}
