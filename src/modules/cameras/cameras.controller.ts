import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CamerasService } from './cameras.service';

class CreateCameraDto {
  tag!: string;
  cameraName!: string;
  imageLink?: string;
}

class UpdateImageDto {
  imageLink!: string;
}

@ApiTags('cameras')
@UseGuards(JwtAuthGuard)
@Controller()
export class CamerasController {
  constructor(private readonly service: CamerasService) {}

  @Get('/api/v1/cameras')
  @ApiOperation({ summary: '모든 카메라 조회' })
  async list() {
    const rows = await this.service.list();
    const data = rows.map((c) => ({
      tag: c.tag,
      camera_name: c.cameraName,
      image_link: c.imageLink,
    }));
    return { success: true, data };
  }

  @Post('/api/v1/cameras')
  @ApiOperation({ summary: '새 카메라 등록' })
  async create(@Body() body: CreateCameraDto) {
    const row = await this.service.create(body);
    const data = {
      tag: row.tag,
      camera_name: row.cameraName,
      image_link: row.imageLink,
    };
    return { success: true, data };
  }

  @Get('/api/v1/cameras/:tag')
  @ApiOperation({ summary: '특정 카메라 조회' })
  async get(@Param('tag') tag: string) {
    const row = await this.service.get(tag);
    const data = {
      tag: row.tag,
      camera_name: row.cameraName,
      image_link: row.imageLink,
    };
    return { success: true, data };
  }

  @Delete('/api/v1/cameras/:tag')
  @ApiOperation({ summary: '카메라 삭제' })
  async delete(@Param('tag') tag: string) {
    const data = await this.service.remove(tag);
    return { success: true, data };
  }

  @Get('/api/v1/cameras/:tag/image')
  @ApiOperation({ summary: '카메라 이미지 조회 ⭐ 핵심 기능' })
  async getImage(@Param('tag') tag: string) {
    const data = await this.service.get(tag);
    return { success: true, image_link: data.imageLink };
  }

  @Patch('/api/v1/cameras/:tag/image')
  @ApiOperation({ summary: '이미지 링크 업데이트 (Shell script용)' })
  async updateImage(@Param('tag') tag: string, @Body() body: UpdateImageDto) {
    const row = await this.service.updateImage(tag, body.imageLink);
    const data = {
      tag: row.tag,
      camera_name: row.cameraName,
      image_link: row.imageLink,
    };
    return { success: true, data };
  }

  @Get('/api/v1/cameras/health')
  @ApiOperation({ summary: '카메라 서비스 상태 확인' })
  async health() {
    return { success: true, status: 'ok' };
  }

  @Get('/api/v1/cameras/info')
  @ApiOperation({ summary: '카메라 서비스 정보 조회' })
  async info() {
    return { success: true, service: 'cameras' };
  }
}
