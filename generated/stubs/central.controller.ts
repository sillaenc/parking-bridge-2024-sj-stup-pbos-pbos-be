import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('central')
@Controller()
export class CentralStubController {
  @Get('/api/v1/central/dashboard')
  @ApiOperation({ summary: '중앙 대시보드 데이터 조회' })
  async get_central_dashboard() {
    throw new HttpException('Not implemented: GET /api/v1/central/dashboard', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/central/health')
  @ApiOperation({ summary: '중앙 대시보드 서비스 상태 확인' })
  async get_central_health() {
    throw new HttpException('Not implemented: GET /api/v1/central/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/central/info')
  @ApiOperation({ summary: '중앙 대시보드 서비스 정보 조회' })
  async get_central_info() {
    throw new HttpException('Not implemented: GET /api/v1/central/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/central/legacy')
  @ApiOperation({ summary: '레거시 중앙 대시보드 조회' })
  async get_central_legacy() {
    throw new HttpException('Not implemented: GET /api/v1/central/legacy', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/central')
  @ApiOperation({ summary: '레거시 중앙 대시보드 (최상위 경로)' })
  async get_central() {
    throw new HttpException('Not implemented: GET /central', HttpStatus.NOT_IMPLEMENTED);
  }

}