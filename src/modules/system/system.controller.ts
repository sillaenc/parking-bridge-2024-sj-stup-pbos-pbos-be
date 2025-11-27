import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { SystemService } from './system.service';

@ApiTags('system')
@Controller('api/v1/system')
export class SystemController {
  constructor(private readonly systemService: SystemService) {}

  @Get('health')
  @ApiOperation({ summary: '시스템/DB 헬스 체크' })
  async health() {
    const result = await this.systemService.healthCheck();
    return {
      success: true,
      ...result,
    };
  }
}
