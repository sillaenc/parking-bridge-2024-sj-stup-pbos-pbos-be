import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpsertPingDto } from './dto/upsert-ping.dto';

@Injectable()
export class MonitoringService {
  constructor(private readonly prisma: PrismaService) {}

  async listPings() {
    return this.prisma.ping.findMany({
      orderBy: { id: 'asc' },
    });
  }

  async upsertPing(dto: UpsertPingDto) {
    const ping = await this.prisma.ping.upsert({
      where: { name_address: { name: dto.name, address: dto.address } },
      update: { isalright: dto.isalright },
      create: {
        name: dto.name,
        address: dto.address,
        isalright: dto.isalright,
      },
    });
    return ping;
  }
}
