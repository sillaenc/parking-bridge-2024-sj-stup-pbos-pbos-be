import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('vehicle')
@Controller()
export class VehicleStubController {
  @Get('/api/v1/vehicle/info')
  @ApiOperation({ summary: '차량 정보 조회' })
  async get_vehicle_info() {
    throw new HttpException('Not implemented: GET /api/v1/vehicle/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/vehicle/location/{vehicleId}')
  @ApiOperation({ summary: '특정 차량 위치 조회' })
  async get_vehicle_location_vehicleId() {
    throw new HttpException('Not implemented: GET /api/v1/vehicle/location/{vehicleId}', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/vehicle/by-tag')
  @ApiOperation({ summary: '태그로 차량 정보 조회 (GET)' })
  async get_vehicle_by_tag() {
    throw new HttpException('Not implemented: GET /api/v1/vehicle/by-tag', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/vehicle/by-tag')
  @ApiOperation({ summary: '태그로 차량 정보 조회 (POST)' })
  async post_vehicle_by_tag() {
    throw new HttpException('Not implemented: POST /api/v1/vehicle/by-tag', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/vehicle/by-plate')
  @ApiOperation({ summary: '번호판으로 차량 위치 조회 (GET)' })
  async get_vehicle_by_plate() {
    throw new HttpException('Not implemented: GET /api/v1/vehicle/by-plate', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/vehicle/by-plate')
  @ApiOperation({ summary: '번호판으로 차량 위치 조회 (POST)' })
  async post_vehicle_by_plate() {
    throw new HttpException('Not implemented: POST /api/v1/vehicle/by-plate', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/vehicle/health')
  @ApiOperation({ summary: '차량 정보 서비스 상태 확인' })
  async get_vehicle_health() {
    throw new HttpException('Not implemented: GET /api/v1/vehicle/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/pabi')
  @ApiOperation({ summary: '레거시 차량 정보 조회 (최상위 경로)' })
  async post_pabi() {
    throw new HttpException('Not implemented: POST /pabi', HttpStatus.NOT_IMPLEMENTED);
  }

}