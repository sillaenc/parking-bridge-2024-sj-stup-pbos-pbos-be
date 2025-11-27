import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { BillboardService } from './billboard.service';

@ApiTags('billboard')
@UseGuards(JwtAuthGuard)
@Controller()
export class BillboardController {
  constructor(private readonly service: BillboardService) {}

  @Get('/api/v1/billboard')
  @ApiOperation({ summary: '전광판 데이터 조회' })
  async list() {
    const data = await this.service.list();
    return { success: true, data };
  }
}
