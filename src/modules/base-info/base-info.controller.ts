import { Body, Controller, Get, Put, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { BaseInfoService } from './base-info.service';

class BaseInfoDto {
  name!: string;
  address!: string;
  latitude?: string;
  longitude?: string;
  manager!: string;
  phoneNumber!: string;
}

@ApiTags('base-info')
@UseGuards(JwtAuthGuard)
@Controller('api/v1/base-info')
export class BaseInfoController {
  constructor(private readonly baseInfoService: BaseInfoService) {}

  @Get()
  @ApiOperation({ summary: '기본 정보 조회' })
  async getBase() {
    const data = await this.baseInfoService.getBase();
    return { success: true, data };
  }

  @Put()
  @ApiOperation({ summary: '기본 정보 수정/생성' })
  async putBase(@Body() body: BaseInfoDto) {
    const data = await this.baseInfoService.upsertBase(body);
    return { success: true, data };
  }

  @Get('health')
  @ApiOperation({ summary: '기본 정보 서비스 상태' })
  async health() {
    return { success: true, status: 'ok' };
  }

  @Get('info')
  @ApiOperation({ summary: '기본 정보 서비스 정보' })
  async info() {
    return { success: true, service: 'base-info' };
  }
}
