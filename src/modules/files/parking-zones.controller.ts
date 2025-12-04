import { Body, Controller, Delete, Get, Param, Post, Put } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { FilesService } from './files.service';
import { CreateParkingZoneDto } from '../parking/dto/create-parking-zone.dto';

@ApiTags('parking-zones')
@Controller('api/v1/parking-zones')
export class ParkingZonesController {
  constructor(private readonly filesService: FilesService) {}

  @Get()
  @ApiOperation({ summary: '주차 구역 목록 조회' })
  async list() {
    const data = await this.filesService.listParkingZones();
    return { success: true, data };
  }

  @Post()
  @ApiOperation({ summary: '주차 구역 생성' })
  async create(@Body() body: CreateParkingZoneDto) {
    const data = await this.filesService.createParkingZone({
      parkingName: body.parkingName,
      fileAddress: body.fileAddress,
      floor: body.floor,
    });
    return { success: true, data };
  }

  @Get('health')
  @ApiOperation({ summary: '주차 구역 서비스 상태 확인' })
  async health() {
    return { success: true, status: 'ok' };
  }

  @Get('info')
  @ApiOperation({ summary: '주차 구역 서비스 정보' })
  async info() {
    return { success: true, service: 'parking-zones' };
  }

  @Get(':name')
  @ApiOperation({ summary: '주차 구역 단건 조회' })
  async getOne(@Param('name') name: string) {
    const data = await this.filesService.getParkingZoneByName(name);
    return { success: true, data };
  }

  @Put(':name')
  @ApiOperation({ summary: '주차 구역 업데이트' })
  async update(@Param('name') name: string, @Body() body: Partial<CreateParkingZoneDto>) {
    const data = await this.filesService.updateParkingZone(name, {
      fileAddress: body.fileAddress,
      floor: body.floor,
    });
    return { success: true, data };
  }

  @Delete(':name')
  @ApiOperation({ summary: '주차 구역 삭제' })
  async remove(@Param('name') name: string) {
    const data = await this.filesService.deleteParkingZone(name);
    return { success: true, data };
  }
}
