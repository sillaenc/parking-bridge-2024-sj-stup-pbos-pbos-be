import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { LedService } from './led.service';

class LegacyLedDto {
  data?: any;
}

@ApiTags('led')
@UseGuards(JwtAuthGuard)
@Controller()
export class LedController {
  constructor(private readonly ledService: LedService) {}

  @Get('/api/v1/led/calculation')
  @ApiOperation({ summary: 'LED 계산 수행 (GET)' })
  async calc() {
    const data = await this.ledService.calculate();
    return { success: true, data };
  }

  @Get('/api/v1/led/health')
  @ApiOperation({ summary: 'LED 계산 서비스 상태 확인' })
  async health() {
    return { success: true, status: 'ok' };
  }

  @Post('/api/v1/led/legacy')
  @ApiOperation({ summary: '레거시 LED 계산 (POST)' })
  async legacy(@Body() _body: LegacyLedDto) {
    const data = await this.ledService.calculate();
    return { success: true, data };
  }

  @Post('/led_cal')
  @ApiOperation({ summary: '레거시 LED 계산 (최상위 경로)' })
  async legacyTop(@Body() _body: LegacyLedDto) {
    const data = await this.ledService.calculate();
    return { success: true, data };
  }
}
