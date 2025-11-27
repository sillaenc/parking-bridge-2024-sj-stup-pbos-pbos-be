import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class BillboardService {
  constructor(private readonly prisma: PrismaService) {}

  async list() {
    const rows = await this.prisma.$queryRaw<
      { floor: string | null; lot_type: number | null; count: bigint }[]
    >`
      SELECT floor, lot_type, COUNT(*) AS count
      FROM "tb_lots"
      WHERE "isUsed" = FALSE AND floor IS NOT NULL
      GROUP BY floor, lot_type
      ORDER BY floor, lot_type
    `;
    return rows.map((r) => ({
      floor: r.floor,
      lot_type: r.lot_type,
      count: Number(r.count),
    }));
  }
}
