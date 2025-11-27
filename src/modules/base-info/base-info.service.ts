import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class BaseInfoService {
  constructor(private readonly prisma: PrismaService) {}

  async getBase() {
    return this.prisma.baseInfo.findFirst({ orderBy: { id: 'asc' } });
  }

  async upsertBase(data: {
    name: string;
    address: string;
    latitude?: string;
    longitude?: string;
    manager: string;
    phoneNumber: string;
  }) {
    return this.prisma.baseInfo.upsert({
      where: { id: 1 },
      update: data,
      create: { id: 1, ...data },
    });
  }
}
