import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('billboard')
@Controller()
export class BillboardStubController {
  @Get('/api/v1/billboard')
  @ApiOperation({ summary: '광고판 API 정보 조회' })
  async get_billboard() {
    throw new HttpException('Not implemented: GET /api/v1/billboard', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/billboard/floor/{floor}')
  @ApiOperation({ summary: '층별 주차 정보 조회' })
  async get_billboard_floor_floor() {
    throw new HttpException('Not implemented: GET /api/v1/billboard/floor/{floor}', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/billboard/floor')
  @ApiOperation({ summary: '층별 주차 정보 업데이트' })
  async post_billboard_floor() {
    throw new HttpException('Not implemented: POST /api/v1/billboard/floor', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/billboard/part-system/control')
  @ApiOperation({ summary: '부분 시스템 제어' })
  async post_billboard_part_system_control() {
    throw new HttpException('Not implemented: POST /api/v1/billboard/part-system/control', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/billboard/health')
  @ApiOperation({ summary: '광고판 서비스 상태 확인' })
  async get_billboard_health() {
    throw new HttpException('Not implemented: GET /api/v1/billboard/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/billboard/info')
  @ApiOperation({ summary: '광고판 서비스 정보 조회' })
  async get_billboard_info() {
    throw new HttpException('Not implemented: GET /api/v1/billboard/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/billboard/legacy')
  @ApiOperation({ summary: '레거시 광고판 조회' })
  async get_billboard_legacy() {
    throw new HttpException('Not implemented: GET /api/v1/billboard/legacy', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/billboard')
  @ApiOperation({ summary: '레거시 광고판 조회 (최상위 경로)' })
  async get_billboard() {
    throw new HttpException('Not implemented: GET /billboard', HttpStatus.NOT_IMPLEMENTED);
  }

}