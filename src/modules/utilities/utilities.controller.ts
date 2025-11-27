import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PrismaService } from '../../prisma/prisma.service';

@ApiTags('utilities')
@UseGuards(JwtAuthGuard)
@Controller()
export class UtilitiesController {
  constructor(private readonly prisma: PrismaService) {}

  @Post('/graphData')
  @ApiOperation({ summary: '레거시 그래프 데이터 조회 (최상위 경로)' })
  async postGraphData() {
    const count = await this.prisma.processedDb.count();
    return { success: true, count };
  }

  @Get('/graphData/test')
  @ApiOperation({ summary: '그래프 데이터 테스트 엔드포인트 (최상위 경로)' })
  async graphDataTest() {
    return { success: true, status: 'ok' };
  }

  @Get('/api/v1/resources')
  @ApiOperation({ summary: '주차장 리소스 조회' })
  async resources() {
    const lots = await this.prisma.lot.count();
    return { success: true, lots };
  }

  @Get('/api/v1/resources/parking-lots')
  @ApiOperation({ summary: '주차 공간 목록 조회' })
  async parkingLots() {
    const data = await this.prisma.lot.findMany({ orderBy: { id: 'asc' } });
    return { success: true, data };
  }

  @Get('/api/v1/resources/parking-lots/raw')
  @ApiOperation({ summary: '주차 공간 원시 데이터 조회' })
  async parkingLotsRaw() {
    const data = await this.prisma.lot.findMany();
    return { success: true, data };
  }

  @Post('/api/v1/resources/refresh')
  @ApiOperation({ summary: '리소스 새로고침' })
  async refresh() {
    return { success: true, refreshed: true };
  }

  @Get('/api/v1/resources/status')
  @ApiOperation({ summary: '리소스 상태 조회' })
  async status() {
    return { success: true, status: 'ok' };
  }

  @Get('/api/v1/resources/health')
  @ApiOperation({ summary: '리소스 관리 서비스 상태' })
  async health() {
    return { success: true, status: 'ok' };
  }

  @Get('/api/v1/resources/info')
  @ApiOperation({ summary: '리소스 관리 서비스 정보' })
  async info() {
    return { success: true, service: 'resources' };
  }

  @Get('/get_resource')
  @ApiOperation({ summary: '레거시 리소스 조회 (최상위 경로)' })
  async legacyGetResource() {
    const data = await this.prisma.lot.findMany();
    return { success: true, data };
  }
}
