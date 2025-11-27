import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DisplayService {
  constructor(private readonly prisma: PrismaService) {}

  async list() {
    return this.prisma.display.findMany({ orderBy: { id: 'asc' } });
  }

  async upsert(tag: string, data: { lotTypeId?: number; point?: string; asset?: string; floor?: string }) {
    return this.prisma.display.upsert({
      where: { tag },
      update: {
        lotTypeId: data.lotTypeId,
        point: data.point,
        asset: data.asset,
        floor: data.floor,
      },
      create: {
        tag,
        lotTypeId: data.lotTypeId,
        point: data.point,
        asset: data.asset,
        floor: data.floor,
      },
    });
  }

  async getByTag(tag: string) {
    return this.prisma.display.findUnique({ where: { tag } });
  }
}
