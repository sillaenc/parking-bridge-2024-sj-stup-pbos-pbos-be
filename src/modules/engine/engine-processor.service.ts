import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Ws4sqliteClient } from './ws4sqlite.client';

@Injectable()
export class EngineProcessorService {
  private readonly logger = new Logger(EngineProcessorService.name);
  private readonly wsClient = new Ws4sqliteClient();
  private lprDisabled = false;
  // stored-statement 호출은 비활성화하고 raw SQL만 사용
  private readonly lprQueryIds: string[] = [];
  private readonly lprRawSql = 'SELECT slot_name, plate_number, entry_time FROM parking_records';

  constructor(private readonly prisma: PrismaService) {}

  private normalizeUrl(url?: string) {
    if (!url) return undefined;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return `http://${url}`;
  }

  private async loadDbSettings() {
    const setting = await this.prisma.dbSetting.findFirst({
      orderBy: { id: 'asc' },
    });
    return {
      engineDb: this.normalizeUrl(setting?.engineDbAddr ?? undefined),
      displayDbLpr: this.normalizeUrl(setting?.displayDbLpr ?? undefined),
    };
  }

  private parseParkingLots(raw: any[]) {
    const tags = new Set<string>();
    const MAX_TAG_LEN = 50;
    const validTag = /^[A-Za-z].+_.+_.+/; // 대략 B1_A01_1_N001 형태만 허용
    for (const row of raw) {
      if (!row?.parking_lot) continue;
      const parts = String(row.parking_lot)
        .split(',')
        .map((p) => p.trim())
        .filter((p) => p && p.toLowerCase() !== 'start');
      parts
        .filter((p) => !p.includes('X000')) // 엔진 오류 슬롯(X000) 스킵
        .filter((p) => validTag.test(p)) // 형식이 맞는 태그만 사용
        .forEach((p) => tags.add(p.slice(0, MAX_TAG_LEN)));
    }
    return Array.from(tags);
  }

  private truncateHour(date: Date) {
    const d = new Date(date);
    d.setMinutes(0, 0, 0);
    return d;
  }
  private truncateDay(date: Date) {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    return d;
  }
  private truncateMonth(date: Date) {
    return new Date(date.getFullYear(), date.getMonth(), 1, 0, 0, 0, 0);
  }
  private truncateYear(date: Date) {
    return new Date(date.getFullYear(), 0, 1, 0, 0, 0, 0);
  }

  async processCycle() {
    const { engineDb: engineDbFromDb, displayDbLpr } = await this.loadDbSettings();

    let engineDb = engineDbFromDb;
    if (!engineDb) {
      this.logger.warn('engineDbAddr not set');
      return { success: false, reason: 'missing engine db addr' };
    }

    try {
      // 1) 엔진 raw 데이터 조회 (#S1)
      const raw = await this.wsClient.query(engineDb, '#S1');
      if (!raw.length) {
        this.logger.warn('no engine data');
        return { success: false, reason: 'no engine data' };
      }

      // raw에서 태그 파싱
      const occupiedTags = this.parseParkingLots(raw);

      // 태그 기준으로 lot이 없으면 생성
      if (occupiedTags.length) {
        for (const tag of occupiedTags) {
          const existing = await this.prisma.lot.findUnique({ where: { tag } });
          if (!existing) {
            await this.prisma.lot.create({ data: { tag, isUsed: false } });
          }
        }
      }

      // 2) rawdata 저장 (Postgres)
      const rawRows = raw.map((row: any) => ({
        recordId: row.id,
        timestamp: row.timestamp ? new Date(row.timestamp) : undefined,
        parkingLot: row.parking_lot,
      }));
      if (rawRows.length) {
        await this.prisma.rawData.createMany({ data: rawRows, skipDuplicates: true });
      }

      // 3) lot 목록 (Postgres)
      const lots = await this.prisma.lot.findMany();
      if (!lots.length) return { success: false, reason: 'no lot info' };

      // 4) 점유 상태 업데이트 + lot_status 기록
      await this.prisma.lot.updateMany({ data: { isUsed: false } });
      const now = new Date();
      for (const lot of lots) {
        const shouldUse = occupiedTags.includes(lot.tag ?? '');
        await this.prisma.lot.update({
          where: { id: lot.id },
          data: { isUsed: shouldUse },
        });
        await this.prisma.lotStatus.create({
          data: {
            lotId: lot.id,
            isParked: shouldUse,
            added: now,
          },
        });
      }

      // 5) 통계 적재 (시/일/월/년) - 중복 방지
      const hourStart = this.truncateHour(now);
      const dayStart = this.truncateDay(now);
      const monthStart = this.truncateMonth(now);
      const yearStart = this.truncateYear(now);

      const lotTypeMap = new Map<number, number | null>();
      lots.forEach((l) => lotTypeMap.set(l.id, l.lotTypeId));

      const makePayload = (flagField: 'hourParking' | 'dayParking' | 'monthParking' | 'yearParking') =>
        lots.map((lot) => ({
          lotId: lot.id,
          carType: lotTypeMap.get(lot.id) ?? null,
          [flagField]: occupiedTags.includes(lot.tag ?? ''),
        }));

      const hourExists = await this.prisma.processedDb.count({
        where: {
          recordedHour: { gte: hourStart, lt: new Date(hourStart.getTime() + 3600 * 1000) },
        },
      });
      if (!hourExists) {
        await this.prisma.processedDb.createMany({
          data: makePayload('hourParking').map((d) => ({ ...d, recordedHour: hourStart })),
        });
      }

      const dayExists = await this.prisma.perDay.count({
        where: {
          recordedDay: { gte: dayStart, lt: new Date(dayStart.getTime() + 24 * 3600 * 1000) },
        },
      });
      if (!dayExists) {
        await this.prisma.perDay.createMany({
          data: makePayload('dayParking').map((d) => ({ ...d, recordedDay: dayStart })),
        });
      }

      const monthExists = await this.prisma.perMonth.count({
        where: {
          recordedMonth: {
            gte: monthStart,
            lt: new Date(monthStart.getFullYear(), monthStart.getMonth() + 1, 1),
          },
        },
      });
      if (!monthExists) {
        await this.prisma.perMonth.createMany({
          data: makePayload('monthParking').map((d) => ({ ...d, recordedMonth: monthStart })),
        });
      }

      const yearExists = await this.prisma.perYear.count({
        where: {
          recordedYear: {
            gte: yearStart,
            lt: new Date(yearStart.getFullYear() + 1, 0, 1),
          },
        },
      });
      if (!yearExists) {
        await this.prisma.perYear.createMany({
          data: makePayload('yearParking').map((d) => ({ ...d, recordedYear: yearStart })),
        });
      }

      // LPR 연계 시도
      if (displayDbLpr && !this.lprDisabled) {
        await this.handleLpr(displayDbLpr);
      }

      this.logger.log(
        `Engine cycle done: total lots ${lots.length}, occupied ${occupiedTags.length}`,
      );
      return { success: true, total: lots.length, occupied: occupiedTags.length };
    } catch (e: any) {
      const status = e?.response?.status;
      const url = e?.config?.url;
      this.logger.error(
        `Engine cycle failed${url ? ` url=${url}` : ''}${status ? ` status=${status}` : ''}`,
        e?.stack || e,
      );
      return { success: false, error: e?.message || 'error', status, url };
    }
  }

  private async handleLpr(displayDbLpr: string) {
    // fallback: raw SQL
    try {
      const rows = await this.wsClient.queryRaw(displayDbLpr, this.lprRawSql);
      if (rows?.length) {
        for (const row of rows) {
          const tag = row.slot_name || row.tag || row.slot || row.parking_lot;
          const plate = row.plate_number || row.plate || row.number;
          const entry = row.entry_time || row.startTime || row.added;
          if (!tag) continue;
          const data: any = { plate: plate ?? null };
          if (entry) {
            const dt = new Date(entry);
            if (!Number.isNaN(dt.getTime())) data.startTime = dt;
          }
          await this.prisma.lot.updateMany({
            where: { tag },
            data,
          });
        }
        return;
      }
    } catch (e: any) {
      this.logger.warn(`LPR raw SQL failed: ${e?.message || e}`);
    }
    this.logger.warn('LPR query failed: no valid statement id found; LPR calls disabled');
    this.lprDisabled = true;
  }
}
