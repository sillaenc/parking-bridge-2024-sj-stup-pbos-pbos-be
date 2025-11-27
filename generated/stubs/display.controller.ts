import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('display')
@Controller()
export class DisplayStubController {
  @Get('/api/v1/display')
  @ApiOperation({ summary: '디스플레이 API 정보 조회' })
  async get_display() {
    throw new HttpException('Not implemented: GET /api/v1/display', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/display/info')
  @ApiOperation({ summary: '디스플레이 정보 조회 (GET)' })
  async get_display_info() {
    throw new HttpException('Not implemented: GET /api/v1/display/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/display/info')
  @ApiOperation({ summary: '디스플레이 정보 업데이트 (POST)' })
  async post_display_info() {
    throw new HttpException('Not implemented: POST /api/v1/display/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/display/bulk-update')
  @ApiOperation({ summary: '디스플레이 일괄 업데이트' })
  async post_display_bulk_update() {
    throw new HttpException('Not implemented: POST /api/v1/display/bulk-update', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/display/health')
  @ApiOperation({ summary: '디스플레이 서비스 상태 확인' })
  async get_display_health() {
    throw new HttpException('Not implemented: GET /api/v1/display/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/display/legacy')
  @ApiOperation({ summary: '레거시 디스플레이 조회' })
  async get_display_legacy() {
    throw new HttpException('Not implemented: GET /api/v1/display/legacy', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/display/legacy')
  @ApiOperation({ summary: '레거시 디스플레이 업데이트' })
  async post_display_legacy() {
    throw new HttpException('Not implemented: POST /api/v1/display/legacy', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/display')
  @ApiOperation({ summary: '레거시 디스플레이 조회 (최상위 경로)' })
  async get_display() {
    throw new HttpException('Not implemented: GET /display', HttpStatus.NOT_IMPLEMENTED);
  }

}