import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class VehicleService {
  constructor(private readonly prisma: PrismaService) {}

  async listAll() {
    return this.prisma.lot.findMany({
      where: { floor: { not: 'ALL' } },
      select: {
        tag: true,
        plate: true,
        startTime: true,
        point: true,
        floor: true,
        isUsed: true,
      },
      orderBy: { tag: 'asc' },
    });
  }

  async getByTag(tag: string) {
    const lot = await this.prisma.lot.findUnique({
      where: { tag },
      select: {
        tag: true,
        plate: true,
        startTime: true,
        point: true,
        floor: true,
        isUsed: true,
      },
    });
    if (!lot) throw new NotFoundException('Vehicle not found');
    return lot;
  }

  async searchByPlate(plate: string) {
    return this.prisma.lot.findMany({
      where: {
        plate: { contains: plate },
        floor: { not: 'ALL' },
      },
      select: {
        tag: true,
        plate: true,
        startTime: true,
        point: true,
        floor: true,
        isUsed: true,
      },
      orderBy: { tag: 'asc' },
    });
  }
}
