import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { StatsRangeDto } from './dto/stats-range.dto';
import { GraphRangeDto } from './dto/graph-range.dto';

@Injectable()
export class StatsService {
  constructor(private readonly prisma: PrismaService) {}

  // 시간별 processed_db 집계 예시 (최근 24시간)
  async hourlySummary() {
    const now = new Date();
    const dayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    const rows = await this.prisma.processedDb.groupBy({
      by: ['recordedHour'],
      where: { recordedHour: { gte: dayAgo } },
      _count: { id: true },
      orderBy: { recordedHour: 'asc' },
    });
    return rows;
  }

  // floor/lot_type별 점유 현황 예시
  async occupancyByFloor() {
    return this.prisma.$queryRaw<
      { floor: string | null; lot_type: number | null; total: bigint; used: bigint }[]
    >`
      SELECT
        floor,
        lot_type,
        COUNT(*) AS total,
        SUM(CASE WHEN "isUsed" = true THEN 1 ELSE 0 END) AS used
      FROM "tb_lots"
      WHERE floor IS NOT NULL AND floor <> 'ALL'
      GROUP BY floor, lot_type
      ORDER BY floor, lot_type
    `;
  }

  async perDayRange(range: StatsRangeDto) {
    return this.prisma.perDay.findMany({
      where: {
        recordedDay: {
          gte: new Date(range.start),
          lte: new Date(range.end),
        },
      },
      orderBy: { recordedDay: 'asc' },
    });
  }

  async perMonthRange(range: StatsRangeDto) {
    return this.prisma.perMonth.findMany({
      where: {
        recordedMonth: {
          gte: new Date(range.start),
          lte: new Date(range.end),
        },
      },
      orderBy: { recordedMonth: 'asc' },
    });
  }

  async perYearRange(range: StatsRangeDto) {
    return this.prisma.perYear.findMany({
      where: {
        recordedYear: {
          gte: new Date(range.start),
          lte: new Date(range.end),
        },
      },
      orderBy: { recordedYear: 'asc' },
    });
  }

  async graphRange(dto: GraphRangeDto) {
    const start = new Date(dto.start);
    const end = new Date(dto.end);
    const floor = dto.floor;
    const lotTypeId = dto.lotTypeId !== undefined ? Number(dto.lotTypeId) : undefined;

    const conditions: string[] = [
      'p."hour_parking" = TRUE',
      'p."recorded_hour" >= $1',
      'p."recorded_hour" <= $2',
    ];
    const params: any[] = [start, end];

    if (floor) {
      conditions.push('l."floor" = $3');
      params.push(floor);
    }
    if (lotTypeId !== undefined && !Number.isNaN(lotTypeId)) {
      conditions.push(`l."lot_type" = $${params.length + 1}`);
      params.push(lotTypeId);
    }

    const where = conditions.join(' AND ');
    const sql = `
      SELECT
        to_char(date_trunc('hour', p."recorded_hour"), 'YYYY-MM-DD"T"HH24:00:00"Z"') AS hour,
        COUNT(*) AS count
      FROM "processed_db" p
      JOIN "tb_lots" l ON p."lot" = l."uid"
      WHERE ${where}
      GROUP BY date_trunc('hour', p."recorded_hour")
      ORDER BY date_trunc('hour', p."recorded_hour")
    `;

    const rows = await this.prisma.$queryRawUnsafe<{ hour: string; count: bigint }[]>(
      sql,
      ...params,
    );
    // 스펙 호환: BigInt -> number, hour 문자열 유지
    return rows.map((r) => ({
      hour: r.hour,
      count: Number(r.count),
    }));
  }

  // === Additional helpers for spec-matched endpoints ===
  async daily(start?: Date, end?: Date) {
    const where: any = {};
    if (start || end) {
      where.recordedDay = {};
      if (start) where.recordedDay.gte = start;
      if (end) where.recordedDay.lte = end;
    }
    return this.prisma.perDay.findMany({
      where,
      orderBy: { recordedDay: 'asc' },
    });
  }

  async weekly() {
    const now = new Date();
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    return this.daily(sevenDaysAgo, now);
  }

  async monthly() {
    const now = new Date();
    const monthAgo = new Date(now);
    monthAgo.setMonth(now.getMonth() - 1);
    return this.prisma.perMonth.findMany({
      where: { recordedMonth: { gte: monthAgo, lte: now } },
      orderBy: { recordedMonth: 'asc' },
    });
  }

  async yearly() {
    const now = new Date();
    const yearAgo = new Date(now);
    yearAgo.setFullYear(now.getFullYear() - 1);
    return this.prisma.perYear.findMany({
      where: { recordedYear: { gte: yearAgo, lte: now } },
      orderBy: { recordedYear: 'asc' },
    });
  }

  async dailyAll() {
    return this.prisma.perDay.findMany({
      orderBy: { recordedDay: 'asc' },
    });
  }

  async monthlyAll() {
    return this.prisma.perMonth.findMany({
      orderBy: { recordedMonth: 'asc' },
    });
  }

  async yearlyAll() {
    return this.prisma.perYear.findMany({
      orderBy: { recordedYear: 'asc' },
    });
  }
}
