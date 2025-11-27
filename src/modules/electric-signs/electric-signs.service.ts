import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class ElectricSignsService {
  constructor(private readonly prisma: PrismaService) {}

  async list() {
    return this.prisma.multipleSigns.findMany({
      orderBy: { id: 'asc' },
    });
  }

  async getById(uid: number) {
    return this.prisma.multipleSigns.findUnique({ where: { id: uid } });
  }

  async upsert(uid: number, parkingLot: string) {
    return this.prisma.multipleSigns.upsert({
      where: { id: uid },
      update: { parkingLot },
      create: { id: uid, parkingLot },
    });
  }

  async remove(uid: number) {
    await this.prisma.multipleSigns.delete({ where: { id: uid } });
    return { deleted: true };
  }

  async stats() {
    const total = await this.prisma.multipleSigns.count();
    return { total };
  }
}
