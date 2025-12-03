import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class BaseInfoService {
  constructor(private readonly prisma: PrismaService) {}

  async getBase() {
    return this.prisma.baseInfo.findFirst({ orderBy: { id: 'asc' } });
  }

  async getAuthBasePayload() {
    const [lotImages, lotTypes, lotDetails] = await this.prisma.$transaction([
      this.prisma.lotImage.findMany(),
      this.prisma.lotType.findMany({ orderBy: { id: 'asc' } }),
      this.prisma.lot.findMany({
        orderBy: { id: 'asc' },
        select: {
          id: true,
          tag: true,
          point: true,
          lotTypeId: true,
          asset: true,
          isUsed: true,
          floor: true,
          plate: true,
          startTime: true,
        },
      }),
    ]);

    const lotTypeIndex = new Map<number, number>();
    lotTypes.forEach((lt, idx) => lotTypeIndex.set(lt.id, idx));

    const lotTypeCounts = lotTypes.map(() => 0);
    for (const lot of lotDetails) {
      if (lot.lotTypeId == null) continue;
      const idx = lotTypeIndex.get(lot.lotTypeId);
      if (idx !== undefined) lotTypeCounts[idx]++;
    }

    const updates = lotTypes
      .map((lt, idx) => ({ id: lt.id, shouldUse: lotTypeCounts[idx] > 0 }))
      .filter((entry) => {
        const lt = lotTypes.find((l) => l.id === entry.id);
        return lt?.isUsed !== entry.shouldUse;
      })
      .map((entry) =>
        this.prisma.lotType.update({
          where: { id: entry.id },
          data: { isUsed: entry.shouldUse },
        }),
      );
    if (updates.length) {
      await this.prisma.$transaction(updates);
    }

    const toNumberOrNull = (v: any) => (v === null || v === undefined ? null : Number(v));

    return {
      lotTypeCounts,
      pixelInfo: lotImages.map((img) => ({
        xbottomright: toNumberOrNull(img.xbottomright),
        ybottomright: toNumberOrNull(img.ybottomright),
      })),
      lotTypes: lotTypes.map((lt) => ({
        uid: lt.id,
        lot_type: lt.lotType ?? '',
        tag: lt.tag ?? '',
        code_format: lt.codeFormat ?? '',
        isUsed: lt.isUsed ?? false,
      })),
      lotDetails: lotDetails.map((lot) => ({
        uid: lot.id,
        ...(lot.tag ? { tag: lot.tag } : {}),
        point: lot.point ?? '',
        lot_type: lot.lotTypeId ?? 0,
        asset: lot.asset ?? '',
        isUsed: lot.isUsed ?? false,
        floor: lot.floor ?? '',
        ...(lot.plate ? { plate: lot.plate } : {}),
        ...(lot.startTime ? { startTime: lot.startTime.toISOString() } : {}),
      })),
    };
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
