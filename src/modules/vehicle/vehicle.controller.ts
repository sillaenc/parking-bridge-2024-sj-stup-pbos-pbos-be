import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { VehicleService } from './vehicle.service';

@ApiTags('vehicle')
@UseGuards(JwtAuthGuard)
@Controller('api/v1/vehicle')
export class VehicleController {
  constructor(private readonly vehicleService: VehicleService) {}

  @Get('info')
  @ApiOperation({ summary: '전체 차량 정보 목록' })
  async list() {
    const data = await this.vehicleService.listAll();
    return { success: true, data };
  }

  @Get('by-tag/:tag')
  @ApiOperation({ summary: '태그로 차량 정보 조회' })
  async byTag(@Param('tag') tag: string) {
    const data = await this.vehicleService.getByTag(tag);
    return { success: true, data };
  }

  @Get('by-plate')
  @ApiOperation({ summary: '번호판으로 차량 위치 조회 (부분 일치)' })
  async byPlate(@Query('plate') plate: string) {
    const data = await this.vehicleService.searchByPlate(plate ?? '');
    return { success: true, data };
  }

  @Get('health')
  @ApiOperation({ summary: '차량 서비스 상태 확인' })
  async health() {
    return { success: true, status: 'ok' };
  }
}
