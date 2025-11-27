import { Controller, Get } from '@nestjs/common';
import { BaseInfoService } from './base-info.service';

@Controller()
export class BaseInfoLegacyController {
  constructor(private readonly baseInfoService: BaseInfoService) {}

  // 레거시 GET /base/get
  @Get('/base/get')
  async legacyGetBase() {
    const data = await this.baseInfoService.getBase();
    return data ?? {};
  }
}
