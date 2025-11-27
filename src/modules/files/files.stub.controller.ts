import { Body, Controller, Get, Param, Post, Put, Delete } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { FilesService } from './files.service';
import { CreateFileDto } from './dto/create-file.dto';

@ApiTags('files')
@Controller()
export class FilesStubController {
  constructor(private readonly filesService: FilesService) {}

  // Stub replaced by actual controller at api/v1/files/*

  @Get('/api/v1/files/:name/status')
  @ApiOperation({ summary: '주차 구역 파일 상태 확인' })
  async get_files_name_status() {
    return { success: true, status: 'ok' };
  }

  @Post('/api/v1/files/:name/sync')
  @ApiOperation({ summary: '주차 구역 파일 동기화' })
  async post_files_name_sync() {
    const stats = await this.filesService.stats();
    return { success: true, synced: true, stats };
  }

  @Get('/api/v1/files/:name/stats')
  @ApiOperation({ summary: '주차 구역 파일 통계' })
  async get_files_name_stats() {
    const data = await this.filesService.stats();
    return { success: true, data };
  }

  @Get('/api/v1/files/health')
  @ApiOperation({ summary: '파일 관리 서비스 상태' })
  async get_files_health() {
    return { success: true, status: 'ok' };
  }

  @Get('/api/v1/files/info')
  @ApiOperation({ summary: '파일 관리 서비스 정보' })
  async get_files_info() {
    return { success: true, service: 'files' };
  }

  @Get('/api/v1/files/legacy')
  @ApiOperation({ summary: '레거시 파일/구역 목록 조회' })
  async get_files_legacy() {
    const data = await this.filesService.listFiles();
    return { success: true, data };
  }

  @Post('/api/v1/files/legacy')
  @ApiOperation({ summary: '레거시 파일/구역 생성' })
  async post_files_legacy(@Body() body: CreateFileDto) {
    const data = await this.filesService.createFile(body);
    return { success: true, data };
  }

  @Get('/api/v1/files/legacy/:name')
  @ApiOperation({ summary: '레거시 특정 파일/구역 조회' })
  async get_files_legacy_name(@Param('name') name: string) {
    const data = await this.filesService.getByFilename(name);
    return { success: true, data };
  }

  @Put('/api/v1/files/legacy/:name')
  @ApiOperation({ summary: '레거시 파일/구역 업데이트' })
  async put_files_legacy_name(@Param('name') name: string, @Body() body: Partial<CreateFileDto>) {
    const data = await this.filesService.updateFile(name, body);
    return { success: true, data };
  }

  @Delete('/api/v1/files/legacy/:name')
  @ApiOperation({ summary: '레거시 파일/구역 삭제' })
  async delete_files_legacy_name(@Param('name') name: string) {
    const data = await this.filesService.softDeleteByFilename(name);
    return { success: true, data };
  }

  @Get('/api/v1/files/legacy/:name/status')
  @ApiOperation({ summary: '레거시 파일/구역 상태' })
  async get_files_legacy_name_status() {
    return { success: true, status: 'ok' };
  }

  @Post('/api/v1/files/legacy/:name/sync')
  @ApiOperation({ summary: '레거시 파일/구역 동기화' })
  async post_files_legacy_name_sync() {
    const stats = await this.filesService.stats();
    return { success: true, synced: true, stats };
  }

  @Get('/api/v1/files/legacy/:name/stats')
  @ApiOperation({ summary: '레거시 파일/구역 통계' })
  async get_files_legacy_name_stats() {
    const data = await this.filesService.stats();
    return { success: true, data };
  }
}
