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
    const { start, end } = this.resolveRange(range);
    return this.prisma.perDay.findMany({
      where: start && end ? { recordedDay: { gte: start, lte: end } } : undefined,
      orderBy: { recordedDay: 'asc' },
    });
  }

  async perMonthRange(range: StatsRangeDto) {
    const { start, end } = this.resolveRange(range);
    return this.prisma.perMonth.findMany({
      where: start && end ? { recordedMonth: { gte: start, lte: end } } : undefined,
      orderBy: { recordedMonth: 'asc' },
    });
  }

  async perYearRange(range: StatsRangeDto) {
    const { start, end } = this.resolveRange(range);
    return this.prisma.perYear.findMany({
      where: start && end ? { recordedYear: { gte: start, lte: end } } : undefined,
      orderBy: { recordedYear: 'asc' },
    });
  }

  async graphRange(dto: GraphRangeDto) {
    if (!dto.startDay || !dto.endDay) {
      throw new Error('startDay and endDay are required');
    }
    const parseKstStart = (day: string) => new Date(`${day}T00:00:00+09:00`);
    const parseKstEnd = (day: string) => new Date(`${day}T23:59:59.999+09:00`);
    const start = parseKstStart(dto.startDay);
    const end = parseKstEnd(dto.endDay);

    const conditions: string[] = [
      'p."hour_parking" = TRUE',
      'p."recorded_hour" >= $1',
      'p."recorded_hour" <= $2',
    ];
    const params: any[] = [start, end];

    const where = conditions.join(' AND ');
    const sql = `
      SELECT
        to_char(
          date_trunc('hour', timezone('Asia/Seoul', p."recorded_hour")),
          'YYYY-MM-DD HH24'
        ) AS recorded_hour,
        p."car_type" AS car_type,
        l."floor" AS floor,
        COUNT(*) AS count
      FROM "processed_db" p
      JOIN "tb_lots" l ON p."lot" = l."uid"
      WHERE ${where}
      GROUP BY date_trunc('hour', timezone('Asia/Seoul', p."recorded_hour")), p."car_type", l."floor"
      ORDER BY date_trunc('hour', timezone('Asia/Seoul', p."recorded_hour")), l."floor", p."car_type"
    `;

    const rows = await this.prisma.$queryRawUnsafe<
      { recorded_hour: string; car_type: number | null; floor: string | null; count: bigint }[]
    >(
      sql,
      ...params,
    );
    // 스펙 호환: BigInt -> number
    return rows.map((r) => ({
      recorded_hour: r.recorded_hour,
      car_type: r.car_type,
      floor: r.floor,
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

  private resolveRange(range: StatsRangeDto) {
    const toKstStart = (day: string) => new Date(`${day}T00:00:00.000+09:00`);
    const toKstEnd = (day: string) => new Date(`${day}T23:59:59.999+09:00`);

    const startStr = range.startDay ?? range.start;
    const endStr = range.endDay ?? range.end;

    const start =
      startStr && !range.start
        ? toKstStart(startStr)
        : startStr
        ? new Date(startStr)
        : undefined;
    const end =
      endStr && !range.end
        ? toKstEnd(endStr)
        : endStr
        ? new Date(endStr)
        : undefined;

    return {
      start,
      end,
    };
  }
}
