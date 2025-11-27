import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateFileDto } from './dto/create-file.dto';
import { LinkZoneFileDto } from './dto/link-zone-file.dto';

const FILE_UPLOAD_DIR = path.join(process.cwd(), 'file', 'uploads');

@Injectable()
export class FilesService {
  constructor(private readonly prisma: PrismaService) {}

  private mapFile(entry: any) {
    return {
      uid: entry.id,
      filename: entry.filename,
      original_filename: entry.originalFilename,
      file_path: entry.filePath,
      file_type: entry.fileType,
      file_category: entry.fileCategory,
      file_size: entry.fileSize,
      mime_type: entry.mimeType,
      description: entry.description,
      uploaded_at: entry.uploadedAt,
      updated_at: entry.updatedAt,
      is_active: entry.isActive,
    };
  }

  private ensureUploadDir() {
    fs.mkdirSync(FILE_UPLOAD_DIR, { recursive: true });
  }

  async saveUploadedFile(
    file: Express.Multer.File,
    meta?: Partial<CreateFileDto>,
  ) {
    this.ensureUploadDir();

    const storedPath = path.join(FILE_UPLOAD_DIR, file.filename);
    fs.writeFileSync(storedPath, file.buffer);

    const dto: CreateFileDto = {
      filename: meta?.filename ?? file.filename,
      originalFilename: meta?.originalFilename ?? file.originalname,
      filePath: storedPath,
      fileType: meta?.fileType ?? path.extname(file.originalname).replace('.', ''),
      fileCategory: meta?.fileCategory ?? 'upload',
      fileSize: meta?.fileSize ?? file.size,
      mimeType: meta?.mimeType ?? file.mimetype,
      description: meta?.description,
    };

    return this.createFile(dto);
  }

  async listFilesystem() {
    this.ensureUploadDir();
    const files = fs.readdirSync(FILE_UPLOAD_DIR);
    return files.map((name) => ({
      name,
      path: path.join(FILE_UPLOAD_DIR, name),
    }));
  }

  async syncFilesystem() {
    const diskFiles = await this.listFilesystem();
    const created: string[] = [];
    for (const f of diskFiles) {
      const exists = await this.prisma.fileEntry.findFirst({
        where: { filePath: f.path },
      });
      if (!exists) {
        const stat = fs.statSync(f.path);
        await this.createFile({
          filename: path.basename(f.path),
          originalFilename: path.basename(f.path),
          filePath: f.path,
          fileType: path.extname(f.path).replace('.', ''),
          fileCategory: 'upload',
          fileSize: stat.size,
          mimeType: 'application/octet-stream',
        } as CreateFileDto);
        created.push(f.path);
      }
    }
    return { created, total: diskFiles.length };
  }

  private mapZone(zone: any) {
    return {
      uid: zone.id,
      parking_name: zone.parkingName,
      file_address: zone.fileAddress,
      floor: zone.floor,
      files: zone.parkingZoneFiles?.map((pzf: any) => this.mapFile(pzf.file)).filter(Boolean) ?? [],
    };
  }

  async listFiles() {
    const rows = await this.prisma.fileEntry.findMany({
      where: { isActive: true },
      orderBy: { uploadedAt: 'desc' },
    });
    return rows.map(this.mapFile);
  }

  async getByFilename(filename: string) {
    const row = await this.prisma.fileEntry.findFirst({
      where: { filename },
    });
    return row ? this.mapFile(row) : null;
  }

  async createFile(dto: CreateFileDto) {
    const row = await this.prisma.fileEntry.create({
      data: {
        filename: dto.filename,
        originalFilename: dto.originalFilename,
        filePath: dto.filePath,
        fileType: dto.fileType,
        fileCategory: dto.fileCategory,
        fileSize: dto.fileSize,
        mimeType: dto.mimeType,
        description: dto.description,
      },
    });
    return this.mapFile(row);
  }

  async updateFile(filename: string, dto: Partial<CreateFileDto>) {
    const row = await this.prisma.fileEntry.update({
      where: { filename },
      data: {
        originalFilename: dto.originalFilename,
        filePath: dto.filePath,
        fileType: dto.fileType,
        fileCategory: dto.fileCategory,
        fileSize: dto.fileSize,
        mimeType: dto.mimeType,
        description: dto.description,
      },
    });
    return this.mapFile(row);
  }

  async stats() {
    const rows = await this.prisma.$queryRaw<
      { file_category: string | null; count: bigint; total_size: bigint | null }[]
    >`
      SELECT file_category, COUNT(*) AS count, SUM(file_size) AS total_size
      FROM "tb_files"
      WHERE is_active = TRUE
      GROUP BY file_category
      ORDER BY file_category
    `;
    return rows.map((r) => ({
      file_category: r.file_category,
      count: Number(r.count),
      total_size: r.total_size ? Number(r.total_size) : 0,
    }));
  }

  async listOrphanedFiles() {
    const rows = await this.prisma.$queryRaw<
      { uid: number; filename: string; file_path: string }[]
    >`
      SELECT f.*
      FROM "tb_files" f
      LEFT JOIN "tb_parking_zone_files" pzf ON f.uid = pzf.file_id
      WHERE pzf.file_id IS NULL AND f.is_active = TRUE
    `;
    return rows;
  }

  async softDelete(fileId: number) {
    await this.prisma.fileEntry.update({
      where: { id: fileId },
      data: { isActive: false },
    });
    return { deleted: true };
  }

  async softDeleteByFilename(filename: string) {
    const file = await this.prisma.fileEntry.findFirst({ where: { filename } });
    if (!file) return { deleted: false };
    return this.softDelete(file.id);
  }

  async linkZoneFile(dto: LinkZoneFileDto) {
    return this.prisma.parkingZoneFile.upsert({
      where: { parkingZoneId_fileId: { parkingZoneId: dto.parkingZoneId, fileId: dto.fileId } },
      update: { filePurpose: dto.filePurpose },
      create: {
        parkingZoneId: dto.parkingZoneId,
        fileId: dto.fileId,
        filePurpose: dto.filePurpose,
      },
    });
  }

  async unlinkZoneFile(dto: LinkZoneFileDto) {
    await this.prisma.parkingZoneFile.delete({
      where: { parkingZoneId_fileId: { parkingZoneId: dto.parkingZoneId, fileId: dto.fileId } },
    });
    return { deleted: true };
  }

  async listZoneFiles(parkingZoneId: number) {
    return this.prisma.parkingZoneFile.findMany({
      where: { parkingZoneId },
      include: { file: true },
      orderBy: { id: 'asc' },
    });
  }

  // Parking zone operations (spec-mapped under files tag)
  async listParkingZones() {
    const rows = await this.prisma.parkingZone.findMany({
      orderBy: { parkingName: 'asc' },
      include: { parkingZoneFiles: { include: { file: true } } },
    });
    return rows.map((z) => this.mapZone(z));
  }

  async getParkingZoneByName(name: string) {
    const zone = await this.prisma.parkingZone.findFirst({
      where: { parkingName: name },
      include: { parkingZoneFiles: { include: { file: true } } },
    });
    return zone ? this.mapZone(zone) : null;
  }

  async createParkingZone(dto: { parkingName: string; fileAddress: string; floor?: string }) {
    const zone = await this.prisma.parkingZone.create({
      data: {
        parkingName: dto.parkingName,
        fileAddress: dto.fileAddress,
        floor: dto.floor,
      },
      include: { parkingZoneFiles: { include: { file: true } } },
    });
    return this.mapZone(zone);
  }

  async updateParkingZone(name: string, dto: { fileAddress?: string; floor?: string }) {
    const zone = await this.prisma.parkingZone.update({
      where: { parkingName: name },
      data: {
        fileAddress: dto.fileAddress,
        floor: dto.floor,
      },
      include: { parkingZoneFiles: { include: { file: true } } },
    });
    return this.mapZone(zone);
  }

  async deleteParkingZone(name: string) {
    await this.prisma.parkingZone.delete({ where: { parkingName: name } });
    return { deleted: true };
  }
}
