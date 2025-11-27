import { Body, Controller, Delete, Get, Param, Put, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ElectricSignsService } from './electric-signs.service';

class UpsertElectricSignDto {
  uid!: number;
  parkingLot!: string;
}

@ApiTags('electric-signs')
@UseGuards(JwtAuthGuard)
@Controller()
export class ElectricSignsController {
  constructor(private readonly service: ElectricSignsService) {}

  @Get('/api/v1/electric-signs')
  @ApiOperation({ summary: '전광판 목록 조회' })
  async list() {
    const rows = await this.service.list();
    const data = rows.map((r) => ({
      uid: r.id,
      parking_lot: r.parkingLot,
    }));
    return { success: true, data };
  }

  @Get('/api/v1/electric-signs/:uid')
  @ApiOperation({ summary: '전광판 단건 조회' })
  async getById(@Param('uid') uid: string) {
    const r = await this.service.getById(Number(uid));
    const data = r
      ? {
          uid: r.id,
          parking_lot: r.parkingLot,
        }
      : null;
    return { success: true, data };
  }

  @Put('/api/v1/electric-signs/:uid')
  @ApiOperation({ summary: '전광판 업데이트/생성' })
  async upsert(@Param('uid') uid: string, @Body() body: UpsertElectricSignDto) {
    const r = await this.service.upsert(Number(uid), body.parkingLot);
    const data = { uid: r.id, parking_lot: r.parkingLot };
    return { success: true, data };
  }

  @Delete('/api/v1/electric-signs/:uid')
  @ApiOperation({ summary: '전광판 삭제' })
  async remove(@Param('uid') uid: string) {
    const data = await this.service.remove(Number(uid));
    return { success: true, data };
  }

  @Get('/api/v1/electric-signs/stats')
  @ApiOperation({ summary: '전광판 통계' })
  async stats() {
    const data = await this.service.stats();
    return { success: true, ...data };
  }
}
