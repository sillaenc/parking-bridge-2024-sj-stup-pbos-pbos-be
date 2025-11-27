import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { EngineService } from './engine.service';
import { EngineProcessorService } from './engine-processor.service';

@ApiTags('engine')
@UseGuards(JwtAuthGuard)
@Controller()
export class EngineController {
  constructor(
    private readonly engineService: EngineService,
    private readonly engineProcessor: EngineProcessorService,
  ) {}

  @Get('/api/v1/engine/data/process')
  @ApiOperation({ summary: '엔진 데이터 수동 처리 트리거' })
  async process() {
    const data = await this.engineProcessor.processCycle();
    return { success: true, data };
  }

  @Get('/api/v1/engine/data/status')
  @ApiOperation({ summary: '현재 주차장 상태 조회' })
  async status() {
    const data = await this.engineService.status();
    return { success: true, data };
  }

  @Get('/api/v1/engine/data/errors')
  @ApiOperation({ summary: '현재 에러 상태 조회' })
  async errors() {
    const data = await this.engineService.errors();
    return { success: true, data };
  }

  @Get('/api/v1/engine/data/statistics')
  @ApiOperation({ summary: '처리 통계 정보 조회' })
  async statistics() {
    const data = await this.engineService.statistics();
    return { success: true, data };
  }

  @Post('/api/v1/engine/data/statistics/trigger')
  @ApiOperation({ summary: '수동 통계 처리 트리거' })
  async triggerStatistics() {
    const data = await this.engineService.statistics();
    return { success: true, triggered: true, data };
  }

  @Get('/api/v1/engine/data/health')
  @ApiOperation({ summary: '엔진 데이터 처리 서비스 헬스 체크' })
  async health() {
    return { success: true, status: 'ok' };
  }
}
