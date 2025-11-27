import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('base-info')
@Controller()
export class Base-infoStubController {
  @Get('/api/v1/parking/information')
  @ApiOperation({ summary: '주차장 기본 정보 조회' })
  async get_parking_information() {
    throw new HttpException('Not implemented: GET /api/v1/parking/information', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/parking/information')
  @ApiOperation({ summary: '주차장 기본 정보 생성' })
  async post_parking_information() {
    throw new HttpException('Not implemented: POST /api/v1/parking/information', HttpStatus.NOT_IMPLEMENTED);
  }

  @Put('/api/v1/parking/information')
  @ApiOperation({ summary: '주차장 기본 정보 업데이트' })
  async put_parking_information() {
    throw new HttpException('Not implemented: PUT /api/v1/parking/information', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/parking/information/statistics')
  @ApiOperation({ summary: '주차장 통계 정보 조회' })
  async get_parking_information_statistics() {
    throw new HttpException('Not implemented: GET /api/v1/parking/information/statistics', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/parking/information/full')
  @ApiOperation({ summary: '주차장 전체 정보 조회 (통계 포함)' })
  async get_parking_information_full() {
    throw new HttpException('Not implemented: GET /api/v1/parking/information/full', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/parking/information/health')
  @ApiOperation({ summary: '기본 정보 서비스 상태 확인' })
  async get_parking_information_health() {
    throw new HttpException('Not implemented: GET /api/v1/parking/information/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/parking/information/info')
  @ApiOperation({ summary: '기본 정보 서비스 정보 조회' })
  async get_parking_information_info() {
    throw new HttpException('Not implemented: GET /api/v1/parking/information/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/parking/information/legacy')
  @ApiOperation({ summary: '레거시 기본 정보 생성/업데이트' })
  async post_parking_information_legacy() {
    throw new HttpException('Not implemented: POST /api/v1/parking/information/legacy', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/parking/information/legacy/get')
  @ApiOperation({ summary: '레거시 기본 정보 조회 (통계 포함)' })
  async get_parking_information_legacy_get() {
    throw new HttpException('Not implemented: GET /api/v1/parking/information/legacy/get', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/base_information')
  @ApiOperation({ summary: '레거시 기본 정보 조회 (최상위 경로)' })
  async get_base_information() {
    throw new HttpException('Not implemented: GET /base_information', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/base_information')
  @ApiOperation({ summary: '레거시 기본 정보 업데이트 (최상위 경로)' })
  async post_base_information() {
    throw new HttpException('Not implemented: POST /base_information', HttpStatus.NOT_IMPLEMENTED);
  }

}