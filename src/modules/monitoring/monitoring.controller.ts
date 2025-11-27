import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UpsertPingDto } from './dto/upsert-ping.dto';
import { MonitoringService } from './monitoring.service';

@ApiTags('monitoring')
@UseGuards(JwtAuthGuard)
@Controller('api/v1/monitoring')
export class MonitoringController {
  constructor(private readonly monitoringService: MonitoringService) {}

  @Get('pings')
  @ApiOperation({ summary: '핑 상태 목록' })
  async list() {
    const data = await this.monitoringService.listPings();
    return { success: true, data };
  }

  @Post('pings')
  @ApiOperation({ summary: '핑 상태 업서트' })
  async upsert(@Body() body: UpsertPingDto) {
    const data = await this.monitoringService.upsertPing(body);
    return { success: true, data };
  }
}
