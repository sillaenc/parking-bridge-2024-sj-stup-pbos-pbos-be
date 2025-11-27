import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CameraSurfaceDto } from './dto/camera-surface.dto';

@Injectable()
export class CameraParkingService {
  constructor(private readonly prisma: PrismaService) {}

  map(surface: any) {
    return {
      uid: surface.id,
      tag: surface.tag,
      engine_code: surface.engineCode,
      uri: surface.uri,
    };
  }

  async list() {
    const rows = await this.prisma.parkingSurface.findMany({ orderBy: { id: 'asc' } });
    return rows.map(this.map);
  }

  async getById(uid: number) {
    const row = await this.prisma.parkingSurface.findUnique({ where: { id: uid } });
    if (!row) throw new NotFoundException('camera surface not found');
    return this.map(row);
  }

  async create(dto: CameraSurfaceDto) {
    const row = await this.prisma.parkingSurface.create({
      data: {
        tag: dto.tag,
        engineCode: dto.engine_code,
        uri: dto.uri,
      },
    });
    return this.map(row);
  }

  async update(uid: number, dto: CameraSurfaceDto) {
    const row = await this.prisma.parkingSurface.update({
      where: { id: uid },
      data: {
        tag: dto.tag,
        engineCode: dto.engine_code,
        uri: dto.uri,
      },
    });
    return this.map(row);
  }

  async remove(uid: number) {
    await this.prisma.parkingSurface.delete({ where: { id: uid } });
    return { deleted: true };
  }
}
