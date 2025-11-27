import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CentralService {
  constructor(private readonly prisma: PrismaService) {}

  async overview() {
    const total = await this.prisma.lot.count({ where: { floor: { not: 'ALL' } } });
    const used = await this.prisma.lot.count({
      where: { floor: { not: 'ALL' }, isUsed: true },
    });
    return {
      total_spaces: total,
      used_spaces: used,
      available_spaces: total - used,
    };
  }

  async byFloor() {
    return this.prisma.$queryRaw<
      { floor: string | null; lot_type: number | null; total: bigint; used: bigint }[]
    >`
      SELECT floor, lot_type, COUNT(*) AS total,
             SUM(CASE WHEN "isUsed" = true THEN 1 ELSE 0 END) AS used
      FROM "tb_lots"
      WHERE floor IS NOT NULL AND floor <> 'ALL'
      GROUP BY floor, lot_type
      ORDER BY floor, lot_type
    `;
  }

  async dashboard() {
    const overview = await this.overview();
    const byFloor = await this.byFloor();
    return { ...overview, by_floor: byFloor };
  }
}
