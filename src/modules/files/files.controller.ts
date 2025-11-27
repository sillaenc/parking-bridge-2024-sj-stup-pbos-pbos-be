import {
  Body,
  Controller,
  Delete,
  Get,
  HttpException,
  HttpStatus,
  Param,
  Post,
  Put,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { CreateFileDto } from './dto/create-file.dto';
import { LinkZoneFileDto } from './dto/link-zone-file.dto';
import { FilesService } from './files.service';
import { CreateParkingZoneDto } from '../parking/dto/create-parking-zone.dto';

@ApiTags('files')
// 레거시 호환을 위해 파일 및 주차존/파일 경로는 공개
@Controller('api/v1/files')
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Get()
  @ApiOperation({ summary: '파일 목록(활성 상태)' })
  async list() {
    const data = await this.filesService.listFiles();
    return { success: true, data };
  }

  @Post()
  @ApiOperation({ summary: '파일 메타데이터 등록' })
  async create(@Body() body: CreateFileDto) {
    if (!body.filename || !body.filePath) {
      throw new HttpException('filename and file_path required', HttpStatus.BAD_REQUEST);
    }
    const data = await this.filesService.createFile(body);
    return { success: true, data };
  }

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({ summary: '파일 업로드 (multipart/form-data)', description: 'field name: file' })
  async upload(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: Partial<CreateFileDto>,
  ) {
    if (!file) {
      throw new HttpException('file required', HttpStatus.BAD_REQUEST);
    }
    const data = await this.filesService.saveUploadedFile(file, body);
    return { success: true, data };
  }

  @Get('stats')
  @ApiOperation({ summary: '파일 카테고리별 통계' })
  async stats() {
    const data = await this.filesService.stats();
    return { success: true, data };
  }

  @Get('orphaned')
  @ApiOperation({ summary: '연결되지 않은 파일 목록' })
  async orphaned() {
    const data = await this.filesService.listOrphanedFiles();
    return { success: true, data };
  }

  @Post('link')
  @ApiOperation({ summary: '주차구역-파일 연결(업서트)' })
  async link(@Body() body: LinkZoneFileDto) {
    const data = await this.filesService.linkZoneFile(body);
    return { success: true, data };
  }

  @Delete('link')
  @ApiOperation({ summary: '주차구역-파일 연결 삭제' })
  async unlink(@Body() body: LinkZoneFileDto) {
    const data = await this.filesService.unlinkZoneFile(body);
    return { success: true, data };
  }

  @Delete(':fileId')
  @ApiOperation({ summary: '파일 소프트 삭제' })
  async deleteFile(@Param('fileId') fileId: string) {
    const data = await this.filesService.softDelete(Number(fileId));
    return { success: true, data };
  }

  @Get('zones/:parkingZoneId')
  @ApiOperation({ summary: '주차구역별 파일 목록' })
  async zoneFiles(@Param('parkingZoneId') parkingZoneId: string) {
    const data = await this.filesService.listZoneFiles(Number(parkingZoneId));
    return { success: true, data };
  }

  // Parking zones (spec places under files tag)
  @Get('/../parking-zones')
  @ApiOperation({ summary: '모든 주차 구역 조회 (파일 포함)' })
  async listZones() {
    const data = await this.filesService.listParkingZones();
    return { success: true, data };
  }

  @Post('/../parking-zones')
  @ApiOperation({ summary: '새 주차 구역 생성 (파일 업로드)' })
  async createZone(@Body() body: CreateParkingZoneDto) {
    if (!body.parkingName || !body.fileAddress) {
      throw new HttpException('parking_name and file_address required', HttpStatus.BAD_REQUEST);
    }
    const data = await this.filesService.createParkingZone(body);
    return { success: true, data };
  }

  @Get('/../parking-zones/:name')
  @ApiOperation({ summary: '특정 주차 구역 조회 (파일 포함)' })
  async getZone(@Param('name') name: string) {
    const data = await this.filesService.getParkingZoneByName(name);
    return { success: true, data };
  }

  @Put('/../parking-zones/:name')
  @ApiOperation({ summary: '주차 구역 업데이트 (파일 교체)' })
  async updateZone(@Param('name') name: string, @Body() body: Partial<CreateParkingZoneDto>) {
    const data = await this.filesService.updateParkingZone(name, {
      fileAddress: body.fileAddress,
      floor: body.floor,
      parkingName: body.parkingName ?? name,
    });
    return { success: true, data };
  }

  @Delete('/../parking-zones/:name')
  @ApiOperation({ summary: '주차 구역 삭제' })
  async deleteZone(@Param('name') name: string) {
    const data = await this.filesService.deleteParkingZone(name);
    return { success: true, data };
  }

  @Get('/../parking-zones/health')
  @ApiOperation({ summary: '주차 구역 서비스 상태 확인' })
  async zonesHealth() {
    return { success: true, status: 'ok' };
  }

  @Get('/../parking-zones/info')
  @ApiOperation({ summary: '주차 구역 서비스 정보 조회' })
  async zonesInfo() {
    return { success: true, service: 'parking-zones' };
  }

  @Get('/../parking-zones/legacy')
  @ApiOperation({ summary: '레거시 주차 구역 목록 조회' })
  async zonesLegacy() {
    const data = await this.filesService.listParkingZones();
    return { success: true, data };
  }

  @Post('/../parking-zones/legacy/insertFile')
  @ApiOperation({ summary: '레거시 파일 삽입' })
  async zonesLegacyInsert(@Body() body: LinkZoneFileDto) {
    const data = await this.filesService.linkZoneFile(body);
    return { success: true, data };
  }

  @Post('/../parking-zones/legacy/deleteFile')
  @ApiOperation({ summary: '레거시 파일 삭제' })
  async zonesLegacyDelete(@Body() body: LinkZoneFileDto) {
    const data = await this.filesService.unlinkZoneFile(body);
    return { success: true, data };
  }

  // Filesystem sync/health/info
  @Get('/../filesystem')
  @ApiOperation({ summary: '파일 시스템 내 모든 파일 조회' })
  async filesystemList() {
    const data = await this.filesService.listFilesystem();
    return { success: true, data };
  }

  @Post('/../filesystem/sync')
  @ApiOperation({ summary: '파일시스템-DB 동기화' })
  async filesystemSync() {
    const data = await this.filesService.syncFilesystem();
    return { success: true, data };
  }

  @Get('/../filesystem/health')
  @ApiOperation({ summary: '파일시스템 상태 확인' })
  async filesystemHealth() {
    return { success: true, status: 'ok' };
  }

  @Get('/../filesystem/info')
  @ApiOperation({ summary: '파일시스템 서비스 정보 조회' })
  async filesystemInfo() {
    return { success: true, service: 'filesystem' };
  }

  @Get('/../files/list')
  @ApiOperation({ summary: '파일 시스템 파일 목록 조회' })
  async filesList() {
    const data = await this.filesService.listFilesystem();
    return { success: true, data };
  }

  @Post('/../files/sync')
  @ApiOperation({ summary: '수동 파일시스템 동기화' })
  async filesSync() {
    const data = await this.filesService.syncFilesystem();
    return { success: true, data };
  }

  @Get('/../files/health')
  @ApiOperation({ summary: '파일시스템 상태 확인' })
  async filesHealth() {
    return { success: true, status: 'ok' };
  }

  @Get('/../files/service-health')
  @ApiOperation({ summary: '주차 구역 관리 서비스 상태' })
  async filesServiceHealth() {
    return { success: true, status: 'ok' };
  }
}
