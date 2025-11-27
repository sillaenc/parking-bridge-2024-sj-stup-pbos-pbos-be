import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CentralService } from './central.service';

@ApiTags('central')
@UseGuards(JwtAuthGuard)
@Controller()
export class CentralController {
  constructor(private readonly centralService: CentralService) {}

  @Get('/api/v1/central/overview')
  @ApiOperation({ summary: '중앙 대시보드 요약(총/사용/여유)' })
  async overview() {
    const data = await this.centralService.overview();
    return { success: true, data };
  }

  @Get('/api/v1/central/by-floor')
  @ApiOperation({ summary: '층/타입별 현황' })
  async byFloor() {
    const data = await this.centralService.byFloor();
    return { success: true, data };
  }

  @Get('/api/v1/central/dashboard')
  @ApiOperation({ summary: '대시보드 전체 응답' })
  async dashboard() {
    const data = await this.centralService.dashboard();
    return { success: true, data };
  }

  // legacy
  @Get('/central')
  @ApiOperation({ summary: '레거시 중앙 대시보드' })
  async legacyCentral() {
    const data = await this.centralService.dashboard();
    return { success: true, data };
  }
}
