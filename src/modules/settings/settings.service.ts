import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SettingsService {
  constructor(private readonly prisma: PrismaService) {}

  mapDbSetting(row: any) {
    if (!row) return null;
    return {
      uid: row.id,
      engine_db_addr: row.engineDbAddr,
      engine_db_id: row.engineDbId,
      engine_db_passwd: row.engineDbPasswd,
    };
  }

  async getDbConfig() {
    const row = await this.prisma.dbSetting.findFirst({ orderBy: { id: 'asc' } });
    return this.mapDbSetting(row);
  }

  async updateEngineDb(addr: string) {
    const row = await this.prisma.dbSetting.upsert({
      where: { id: 1 },
      update: { engineDbAddr: addr },
      create: { id: 1, engineDbAddr: addr },
    });
    return this.mapDbSetting(row);
  }

  async updateDbConfig(data: Partial<{ engineDbAddr: string }>) {
    const row = await this.prisma.dbSetting.upsert({
      where: { id: 1 },
      update: data,
      create: { id: 1, ...data },
    });
    return this.mapDbSetting(row);
  }

  async getSetting(key: string) {
    const row = await this.prisma.setting.findUnique({ where: { key } });
    if (!row) return null;
    return { uid: row.id, key: row.key, value: row.value };
  }

  async setSetting(key: string, value?: string) {
    const row = await this.prisma.setting.upsert({
      where: { key },
      update: { value },
      create: { key, value },
    });
    return row;
  }
}
