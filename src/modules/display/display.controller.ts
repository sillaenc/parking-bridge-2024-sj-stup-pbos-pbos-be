import { Body, Controller, Get, Param, Put, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { DisplayService } from './display.service';

class UpsertDisplayDto {
  lotTypeId?: number;
  point?: string;
  asset?: string;
  floor?: string;
}

@ApiTags('display')
@UseGuards(JwtAuthGuard)
@Controller()
export class DisplayController {
  constructor(private readonly service: DisplayService) {}

  @Get('/api/v1/display')
  @ApiOperation({ summary: '디스플레이 목록' })
  async list() {
    const rows = await this.service.list();
    const data = rows.map((r) => ({
      tag: r.tag,
      lot_type: r.lotTypeId,
      point: r.point,
      asset: r.asset,
      floor: r.floor,
    }));
    return { success: true, data };
  }

  @Get('/api/v1/display/:tag')
  @ApiOperation({ summary: '디스플레이 단건 조회' })
  async getOne(@Param('tag') tag: string) {
    const r = await this.service.getByTag(tag);
    const data = r
      ? {
          tag: r.tag,
          lot_type: r.lotTypeId,
          point: r.point,
          asset: r.asset,
          floor: r.floor,
        }
      : null;
    return { success: true, data };
  }

  @Put('/api/v1/display/:tag')
  @ApiOperation({ summary: '디스플레이 업데이트/생성' })
  async upsert(@Param('tag') tag: string, @Body() body: UpsertDisplayDto) {
    const r = await this.service.upsert(tag, body);
    const data = {
      tag: r.tag,
      lot_type: r.lotTypeId,
      point: r.point,
      asset: r.asset,
      floor: r.floor,
    };
    return { success: true, data };
  }
}
