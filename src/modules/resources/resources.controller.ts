import { Body, Controller, Get, Param, Put, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UpsertSettingDto } from './dto/upsert-setting.dto';
import { ResourcesService } from './resources.service';

@ApiTags('resources')
@UseGuards(JwtAuthGuard)
@Controller('api/v1/resources')
export class ResourcesController {
  constructor(private readonly resourcesService: ResourcesService) {}

  @Get('settings')
  @ApiOperation({ summary: 'settings 전체 목록' })
  async list() {
    const data = await this.resourcesService.listSettings();
    return { success: true, data };
  }

  @Get('settings/:key')
  @ApiOperation({ summary: '설정 단건 조회' })
  async get(@Param('key') key: string) {
    const data = await this.resourcesService.getSetting(key);
    return { success: true, data };
  }

  @Put('settings/:key')
  @ApiOperation({ summary: '설정 저장/업데이트' })
  async upsert(@Param('key') key: string, @Body() body: UpsertSettingDto) {
    const data = await this.resourcesService.upsertSetting({
      key,
      value: body.value,
    });
    return { success: true, data };
  }
}
