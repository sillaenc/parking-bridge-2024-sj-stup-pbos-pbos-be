import { Body, Controller, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateParkingZoneDto } from './dto/create-parking-zone.dto';
import { CreateLotDto } from './dto/create-lot.dto';
import { CreateLotTypeDto } from './dto/create-lot-type.dto';
import { UpdateBaseInfoDto } from './dto/update-base-info.dto';
import { UpdateLotStatusDto } from './dto/update-lot-status.dto';
import { SearchVehicleDto } from './dto/search-vehicle.dto';
import { ParkingService } from './parking.service';

@ApiTags('parking')
@Controller('api/v1/parking')
export class ParkingController {
  constructor(private readonly parkingService: ParkingService) {}

  @UseGuards(JwtAuthGuard)
  @Get('zones')
  @ApiOperation({ summary: '주차 구역 목록' })
  async getZones() {
    const zones = await this.parkingService.listZones();
    return { success: true, data: zones };
  }

  @UseGuards(JwtAuthGuard)
  @Post('zones')
  @ApiOperation({ summary: '주차 구역 생성' })
  async createZone(@Body() body: CreateParkingZoneDto) {
    const zone = await this.parkingService.createZone(body);
    return { success: true, data: zone };
  }

  @UseGuards(JwtAuthGuard)
  @Get('lots')
  @ApiOperation({ summary: '주차 면/LOT 목록' })
  async getLots() {
    const lots = await this.parkingService.listLots();
    return { success: true, data: lots };
  }

  @UseGuards(JwtAuthGuard)
  @Get('lot-types')
  @ApiOperation({ summary: '주차 면 타입 목록' })
  async getLotTypes() {
    const types = await this.parkingService.listLotTypes();
    return { success: true, data: types };
  }

  @UseGuards(JwtAuthGuard)
  @Post('lot-types')
  @ApiOperation({ summary: '주차 면 타입 생성' })
  async createLotType(@Body() body: CreateLotTypeDto) {
    const type = await this.parkingService.createLotType(body);
    return { success: true, data: type };
  }

  @UseGuards(JwtAuthGuard)
  @Get('base')
  @ApiOperation({ summary: '주차장 기본 정보 조회' })
  async getBase() {
    const base = await this.parkingService.getBaseInfo();
    return { success: true, data: base };
  }

  @UseGuards(JwtAuthGuard)
  @Put('base')
  @ApiOperation({ summary: '주차장 기본 정보 저장/업데이트' })
  async saveBase(@Body() body: UpdateBaseInfoDto) {
    const base = await this.parkingService.upsertBaseInfo(body);
    return { success: true, data: base };
  }

  @UseGuards(JwtAuthGuard)
  @Post('lots')
  @ApiOperation({ summary: '주차 면 생성' })
  async createLot(@Body() body: CreateLotDto) {
    const lot = await this.parkingService.createLot(body);
    return { success: true, data: lot };
  }

  @UseGuards(JwtAuthGuard)
  @Put('lots/:tag/status')
  @ApiOperation({ summary: '주차 면 상태 업데이트(점유/차량정보)' })
  async updateLotStatus(@Param('tag') tag: string, @Body() body: UpdateLotStatusDto) {
    const lot = await this.parkingService.updateLotStatus(tag, body);
    return { success: true, data: lot };
  }

  @UseGuards(JwtAuthGuard)
  @Post('vehicles/search')
  @ApiOperation({ summary: '차량 조회(tag 또는 plate like)' })
  async searchVehicle(@Body() body: SearchVehicleDto) {
    const data = await this.parkingService.searchVehicle(body);
    return { success: true, data };
  }

  // Legacy pabi routes
  @Post('/pabi')
  @ApiOperation({ summary: '레거시 pabi 엔드포인트 (tag/car)' })
  async legacyPabi(@Body() body: any) {
    const tag = body?.tag;
    const plate = body?.car || body?.plate;
    const data = await this.parkingService.searchVehicle({ tag, plate });
    return { success: true, data };
  }

  @Post('/api/v1/parking/pabi/tag')
  @ApiOperation({ summary: '태그로 주차 구역 차량 정보 조회 (레거시 호환)' })
  async pabiTag(@Body() body: any) {
    const data = await this.parkingService.searchVehicle({ tag: body?.tag });
    return { success: true, data };
  }

  @Post('/api/v1/parking/pabi/car')
  @ApiOperation({ summary: '번호판으로 차량 위치 조회 (레거시 호환)' })
  async pabiCar(@Body() body: any) {
    const plate = body?.plate || body?.car;
    const data = await this.parkingService.searchVehicle({ plate });
    return { success: true, data };
  }
}
