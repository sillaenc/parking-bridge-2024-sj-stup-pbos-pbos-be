import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CameraParkingService } from './camera-parking.service';
import { CameraSurfaceDto } from './dto/camera-surface.dto';

@ApiTags('settings')
@UseGuards(JwtAuthGuard)
@Controller()
export class CameraParkingController {
  constructor(private readonly service: CameraParkingService) {}

  @Get('/api/v1/settings/camera-parking/surfaces')
  @ApiOperation({ summary: '카메라 표면 목록' })
  async list() {
    const data = await this.service.list();
    return { success: true, data };
  }

  @Post('/api/v1/settings/camera-parking/surfaces')
  @ApiOperation({ summary: '카메라 표면 생성' })
  async create(@Body() body: CameraSurfaceDto) {
    const data = await this.service.create(body);
    return { success: true, data };
  }

  @Get('/api/v1/settings/camera-parking/surfaces/:surfaceId')
  @ApiOperation({ summary: '카메라 표면 조회' })
  async getOne(@Param('surfaceId') surfaceId: string) {
    const data = await this.service.getById(Number(surfaceId));
    return { success: true, data };
  }

  @Put('/api/v1/settings/camera-parking/surfaces/:surfaceId')
  @ApiOperation({ summary: '카메라 표면 수정' })
  async update(
    @Param('surfaceId') surfaceId: string,
    @Body() body: CameraSurfaceDto,
  ) {
    const data = await this.service.update(Number(surfaceId), body);
    return { success: true, data };
  }

  @Delete('/api/v1/settings/camera-parking/surfaces/:surfaceId')
  @ApiOperation({ summary: '카메라 표면 삭제' })
  async remove(@Param('surfaceId') surfaceId: string) {
    const data = await this.service.remove(Number(surfaceId));
    return { success: true, data };
  }

  @Get('/api/v1/settings/camera-parking/health')
  @ApiOperation({ summary: '카메라 주차 서비스 상태 확인' })
  async health() {
    return { success: true, status: 'ok' };
  }

  @Get('/api/v1/settings/camera-parking/info')
  @ApiOperation({ summary: '카메라 주차 서비스 정보' })
  async info() {
    return { success: true, service: 'camera-parking' };
  }

  // legacy top-level
  @Get('/settings_cam_parking_area')
  @ApiOperation({ summary: '레거시 카메라 주차 구역 설정 (최상위 경로)' })
  async legacyList() {
    const data = await this.service.list();
    return { success: true, data };
  }
}
