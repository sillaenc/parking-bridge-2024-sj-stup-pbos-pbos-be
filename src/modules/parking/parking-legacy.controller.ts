import { Body, Controller, Get, Post } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { ParkingService } from './parking.service';
import { LegacyParkingAreaDto } from './dto/legacy-parking-area.dto';
import { ChangeLotTypeDto } from './dto/change-lot-type.dto';

@ApiTags('parking-legacy')
@Controller()
export class ParkingLegacyController {
  constructor(private readonly parkingService: ParkingService) {}

  @Get('/settings/parking_area')
  @ApiOperation({ summary: '레거시 주차 구역 목록(슬래시 버전)' })
  async listSlash() {
    const data = await this.parkingService.legacyListZones();
    return { success: true, data };
  }

  @Get('/settings_parking_area')
  @ApiOperation({ summary: '레거시 주차 구역 목록(언더스코어 버전)' })
  async listUnderscore() {
    const data = await this.parkingService.legacyListZones();
    return { success: true, data };
  }

  @Post('/settings/parking_area/insertFile')
  @ApiOperation({ summary: '레거시 주차 구역 추가(슬래시 버전)' })
  async insertSlash(@Body() body: LegacyParkingAreaDto) {
    const data = await this.parkingService.legacyInsertZone(body);
    return { success: true, data };
  }

  @Post('/settings_parking_area/insertFile')
  @ApiOperation({ summary: '레거시 주차 구역 추가(언더스코어 버전)' })
  async insertUnderscore(@Body() body: LegacyParkingAreaDto) {
    const data = await this.parkingService.legacyInsertZone(body);
    return { success: true, data };
  }

  @Post('/settings/parking_area/updateFile')
  @ApiOperation({ summary: '레거시 주차 구역 업데이트(슬래시 버전)' })
  async updateSlash(@Body() body: LegacyParkingAreaDto) {
    const data = await this.parkingService.legacyUpdateZone(body);
    return { success: true, data };
  }

  @Post('/settings_parking_area/updateFile')
  @ApiOperation({ summary: '레거시 주차 구역 업데이트(언더스코어 버전)' })
  async updateUnderscore(@Body() body: LegacyParkingAreaDto) {
    const data = await this.parkingService.legacyUpdateZone(body);
    return { success: true, data };
  }

  @Post('/settings/parking_area/deleteFile')
  @ApiOperation({ summary: '레거시 주차 구역 삭제(슬래시 버전)' })
  async deleteSlash(@Body('parking_name') parkingName: string) {
    const data = await this.parkingService.legacyDeleteZone(parkingName);
    return { success: true, data };
  }

  @Post('/settings_parking_area/deleteFile')
  @ApiOperation({ summary: '레거시 주차 구역 삭제(언더스코어 버전)' })
  async deleteUnderscore(@Body('parking_name') parkingName: string) {
    const data = await this.parkingService.legacyDeleteZone(parkingName);
    return { success: true, data };
  }

  @Post('/settings/parking_area/ChangeLotType')
  @ApiOperation({ summary: '레거시 LOT 타입/태그 변경(슬래시 버전)' })
  async changeLotTypeSlash(@Body() body: ChangeLotTypeDto) {
    const data = await this.parkingService.legacyChangeLotType(body);
    return { success: true, data };
  }

  @Post('/settings_parking_area/ChangeLotType')
  @ApiOperation({ summary: '레거시 LOT 타입/태그 변경(언더스코어 버전)' })
  async changeLotTypeUnderscore(@Body() body: ChangeLotTypeDto) {
    const data = await this.parkingService.legacyChangeLotType(body);
    return { success: true, data };
  }
}
