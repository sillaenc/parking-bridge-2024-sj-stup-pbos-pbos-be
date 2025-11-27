import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateParkingZoneDto } from './dto/create-parking-zone.dto';
import { CreateLotDto } from './dto/create-lot.dto';
import { UpdateLotStatusDto } from './dto/update-lot-status.dto';
import { CreateLotTypeDto } from './dto/create-lot-type.dto';
import { UpdateBaseInfoDto } from './dto/update-base-info.dto';
import { SearchVehicleDto } from './dto/search-vehicle.dto';

@Injectable()
export class ParkingService {
  constructor(private readonly prisma: PrismaService) {}

  async listZones() {
    return this.prisma.parkingZone.findMany({
      orderBy: { id: 'asc' },
    });
  }

  async createZone(dto: CreateParkingZoneDto) {
    return this.prisma.parkingZone.create({
      data: {
        parkingName: dto.parkingName,
        fileAddress: dto.fileAddress,
        floor: dto.floor,
      },
    });
  }

  async listLots() {
    return this.prisma.lot.findMany({
      orderBy: { id: 'asc' },
      include: {
        lotType: true,
      },
    });
  }

  async listLotTypes() {
    return this.prisma.lotType.findMany({
      orderBy: { id: 'asc' },
    });
  }

  async createLotType(dto: CreateLotTypeDto) {
    return this.prisma.lotType.create({
      data: {
        lotType: dto.lotType,
        tag: dto.tag,
        codeFormat: dto.codeFormat,
        isUsed: dto.isUsed,
      },
    });
  }

  async createLot(dto: CreateLotDto) {
    return this.prisma.lot.create({
      data: {
        tag: dto.tag,
        lotTypeId: dto.lotTypeId,
        point: dto.point,
        asset: dto.asset,
        floor: dto.floor,
        isUsed: dto.isUsed ?? false,
        plate: dto.plate,
        startTime: dto.startTime ? new Date(dto.startTime) : undefined,
      },
      include: { lotType: true },
    });
  }

  async updateLotStatus(tag: string, dto: UpdateLotStatusDto) {
    const updated = await this.prisma.lot.update({
      where: { tag },
      data: {
        isUsed: dto.isUsed,
        plate: dto.plate,
        startTime: dto.startTime ? new Date(dto.startTime) : undefined,
      },
      include: { lotType: true },
    });

    // 상태 로그 기록(tb_lot_status)
    await this.prisma.lotStatus.create({
      data: {
        lotId: updated.id,
        isParked: dto.isUsed ?? updated.isUsed,
        added: new Date(),
      },
    });

    return updated;
  }

  async searchVehicle(dto: SearchVehicleDto) {
    if (dto.tag) {
      const res = await this.prisma.lot.findUnique({
        where: { tag: dto.tag },
        select: {
          tag: true,
          plate: true,
          startTime: true,
          point: true,
          floor: true,
          isUsed: true,
        },
      });
      return res
        ? [
            {
              tag: res.tag,
              plate: res.plate,
              startTime: res.startTime,
              point: res.point,
              floor: res.floor,
              isUsed: res.isUsed,
            },
          ]
        : [];
    }

    if (dto.plate) {
      const rows = await this.prisma.lot.findMany({
        where: {
          plate: { contains: dto.plate },
          isUsed: true,
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
      return rows.map((r) => ({
        tag: r.tag,
        plate: r.plate,
        startTime: r.startTime,
        point: r.point,
        floor: r.floor,
        isUsed: r.isUsed,
      }));
    }

    return [];
  }

  async getBaseInfo() {
    const base = await this.prisma.baseInfo.findFirst({
      orderBy: { id: 'asc' },
    });
    return base;
  }

  async upsertBaseInfo(dto: UpdateBaseInfoDto) {
    const base = await this.prisma.baseInfo.upsert({
      where: { id: 1 },
      update: {
        name: dto.name,
        address: dto.address,
        latitude: dto.latitude,
        longitude: dto.longitude,
        manager: dto.manager,
        phoneNumber: dto.phoneNumber,
      },
      create: {
        id: 1,
        name: dto.name,
        address: dto.address,
        latitude: dto.latitude,
        longitude: dto.longitude,
        manager: dto.manager,
        phoneNumber: dto.phoneNumber,
      },
    });
    return base;
  }
}
