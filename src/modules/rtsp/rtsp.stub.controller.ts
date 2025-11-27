import { Body, Controller, Delete, Get, Param, Post, Put, Res } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Response } from 'express';
import { RtspService } from './rtsp.service';
import { CreateCameraDto } from './dto/create-camera.dto';
import { RtspImageDto } from './dto/rtsp-image.dto';

@ApiTags('rtsp')
@Controller()
export class RtspStubController {
  constructor(private readonly rtspService: RtspService) {}

  @Get('/api/v1/rtsp/cameras')
  @ApiOperation({ summary: 'RTSP 카메라 전체 조회' })
  async get_rtsp_cameras() {
    const data = await this.rtspService.listCameras();
    return { success: true, data };
  }

  @Post('/api/v1/rtsp/cameras')
  @ApiOperation({ summary: 'RTSP 카메라 등록' })
  async post_rtsp_cameras(@Body() body: CreateCameraDto) {
    const data = await this.rtspService.createCamera(body);
    return { success: true, data };
  }

  @Get('/api/v1/rtsp/cameras/:tag')
  @ApiOperation({ summary: '특정 RTSP 카메라 조회' })
  async get_rtsp_cameras_tag(@Param('tag') tag: string) {
    const data = await this.rtspService.getByTag(tag);
    return { success: true, data };
  }

  @Put('/api/v1/rtsp/cameras/:tag')
  @ApiOperation({ summary: 'RTSP 카메라 업데이트' })
  async put_rtsp_cameras_tag(@Param('tag') tag: string, @Body() body: CreateCameraDto) {
    const data = await this.rtspService.updateCamera(tag, body);
    return { success: true, data };
  }

  @Delete('/api/v1/rtsp/cameras/:tag')
  @ApiOperation({ summary: 'RTSP 카메라 삭제' })
  async delete_rtsp_cameras_tag(@Param('tag') tag: string) {
    const data = await this.rtspService.deleteCamera(tag);
    return { success: true, data };
  }

  @Get('/api/v1/rtsp/cameras/:tag/image')
  @ApiOperation({ summary: '카메라 이미지 조회' })
  async get_rtsp_cameras_tag_image(@Param('tag') tag: string, @Res() res: Response) {
    const img = await this.rtspService.readImage(tag);
    if (!img) {
      return res.status(404).json({ success: false, message: 'Image not found' });
    }
    res.setHeader('Content-Type', 'image/jpeg');
    return res.send(img.buffer);
  }

  @Post('/api/v1/rtsp/cameras/:tag/image')
  @ApiOperation({ summary: '카메라 이미지 업로드' })
  async post_rtsp_cameras_tag_image(@Param('tag') tag: string, @Body() body: RtspImageDto) {
    const data = await this.rtspService.saveImage(tag, body);
    return { success: true, data };
  }

  @Put('/api/v1/rtsp/cameras/:tag/image')
  @ApiOperation({ summary: '카메라 이미지 경로 업데이트' })
  async put_rtsp_cameras_tag_image(@Param('tag') tag: string, @Body() body: RtspImageDto) {
    const data = await this.rtspService.saveImage(tag, body);
    return { success: true, data };
  }

  @Get('/api/v1/rtsp/health')
  @ApiOperation({ summary: 'RTSP 서비스 상태' })
  async get_rtsp_health() {
    return { success: true, status: 'ok' };
  }

  @Post('/api/v1/rtsp/trigger')
  @ApiOperation({ summary: '수동 캡처 실행' })
  async trigger() {
    const data = await this.rtspService.triggerAllCaptures();
    return { success: true, data };
  }

  @Get('/api/v1/rtsp/image/:tag')
  @ApiOperation({ summary: '특정 태그의 최신 캡처 이미지 조회' })
  async image(@Param('tag') tag: string, @Res() res: Response) {
    const img = await this.rtspService.readImage(tag);
    if (!img) {
      return res.status(404).json({ success: false, message: 'Image not found' });
    }
    res.setHeader('Content-Type', 'image/jpeg');
    return res.send(img.buffer);
  }

  @Get('/api/v1/rtsp/info')
  @ApiOperation({ summary: 'RTSP 서비스 정보' })
  async get_rtsp_info() {
    return { success: true, service: 'rtsp' };
  }

  @Get('/api/v1/rtsp/status')
  @ApiOperation({ summary: 'RTSP 상태 조회' })
  async get_rtsp_status() {
    return { success: true, status: 'running' };
  }
}
