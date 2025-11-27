import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CamerasService {
  constructor(private readonly prisma: PrismaService) {}

  async list() {
    return this.prisma.camera.findMany({
      orderBy: { id: 'asc' },
    });
  }

  async create(dto: { tag: string; cameraName: string; imageLink?: string }) {
    return this.prisma.camera.create({
      data: {
        tag: dto.tag,
        cameraName: dto.cameraName,
        imageLink: dto.imageLink,
      },
    });
  }

  async get(tag: string) {
    const cam = await this.prisma.camera.findUnique({ where: { tag } });
    if (!cam) throw new NotFoundException('Camera not found');
    return cam;
  }

  async remove(tag: string) {
    await this.prisma.camera.delete({ where: { tag } });
    return { deleted: true };
  }

  async updateImage(tag: string, imageLink: string) {
    const cam = await this.prisma.camera.update({
      where: { tag },
      data: { imageLink },
    });
    return cam;
  }
}
