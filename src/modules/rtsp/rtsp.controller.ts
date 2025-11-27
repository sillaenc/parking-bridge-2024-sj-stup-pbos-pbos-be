import { Body, Controller, Delete, Get, Param, Post, Put, Res, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Response } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateCameraDto } from './dto/create-camera.dto';
import { RtspImageDto } from './dto/rtsp-image.dto';
import { RtspService } from './rtsp.service';

@ApiTags('rtsp')
@UseGuards(JwtAuthGuard)
@Controller('api/v1/rtsp')
export class RtspController {
  constructor(private readonly rtspService: RtspService) {}

  @Get('cameras')
  @ApiOperation({ summary: 'RTSP 카메라 목록' })
  async list() {
    const data = await this.rtspService.listCameras();
    return { success: true, data };
  }

  @Post('cameras')
  @ApiOperation({ summary: 'RTSP 카메라 등록' })
  async create(@Body() body: CreateCameraDto) {
    const data = await this.rtspService.createCamera(body);
    return { success: true, data };
  }

  @Put('cameras/:tag')
  @ApiOperation({ summary: 'RTSP 카메라 수정' })
  async update(@Param('tag') tag: string, @Body() body: CreateCameraDto) {
    const data = await this.rtspService.updateCamera(tag, body);
    return { success: true, data };
  }

  @Delete('cameras/:tag')
  @ApiOperation({ summary: 'RTSP 카메라 삭제' })
  async remove(@Param('tag') tag: string) {
    const data = await this.rtspService.deleteCamera(tag);
    return { success: true, data };
  }

  @Get('stats')
  @ApiOperation({ summary: 'RTSP 통계(고유 주소/총 태그)' })
  async stats() {
    const data = await this.rtspService.stats();
    return { success: true, ...data };
  }

  @Get('addresses')
  @ApiOperation({ summary: 'RTSP 주소 목록(중복 제거)' })
  async addresses() {
    const rows = await this.rtspService.distinctRtspAddresses();
    const data = rows.map((r) => r.rtsp_address);
    return { success: true, data };
  }

  @Post('cameras/:tag/image')
  @ApiOperation({ summary: '카메라 이미지 업로드(Base64 또는 경로)' })
  async uploadImage(@Param('tag') tag: string, @Body() body: RtspImageDto) {
    const data = await this.rtspService.saveImage(tag, body);
    return { success: true, data };
  }

  @Put('cameras/:tag/image')
  @ApiOperation({ summary: '카메라 이미지 경로 업데이트(Base64/경로)' })
  async updateImage(@Param('tag') tag: string, @Body() body: RtspImageDto) {
    const data = await this.rtspService.saveImage(tag, body);
    return { success: true, data };
  }

  @Get('cameras/:tag/image')
  @ApiOperation({ summary: '카메라 이미지 조회' })
  async getImage(@Param('tag') tag: string, @Res() res: Response) {
    const img = await this.rtspService.readImage(tag);
    if (!img) {
      return res.status(404).json({ success: false, message: 'Image not found' });
    }
    res.setHeader('Content-Type', 'image/jpeg');
    return res.send(img.buffer);
  }

  @Post('trigger')
  @ApiOperation({ summary: '수동 캡처 실행' })
  async trigger() {
    const data = await this.rtspService.triggerAllCaptures();
    return { success: true, data };
  }
}
