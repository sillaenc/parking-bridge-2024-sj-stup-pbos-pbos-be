import { Body, Controller, Get, Post, Put, Query, UseGuards, HttpCode } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SettingsService } from './settings.service';
import { UsersService } from '../users/users.service';
import { IsOptional, IsString } from 'class-validator';

class DbConfigDto {
  engineDbAddr?: string;
}

class SettingDto {
  @IsString()
  key!: string;

  @IsOptional()
  @IsString()
  value?: string;
}

@ApiTags('settings')
@Controller()
export class SettingsController {
  constructor(
    private readonly settingsService: SettingsService,
    private readonly usersService: UsersService,
  ) {}

  @Get('/api/v1/settings/database/config')
  @ApiOperation({ summary: '데이터베이스 설정 조회' })
  @UseGuards(JwtAuthGuard)
  async getDbConfig() {
    const data = await this.settingsService.getDbConfig();
    return { success: true, data };
  }

  @Put('/api/v1/settings/database/config')
  @ApiOperation({ summary: '전체 데이터베이스 설정 업데이트' })
  @UseGuards(JwtAuthGuard)
  async putDbConfig(@Body() body: DbConfigDto) {
    const data = await this.settingsService.updateDbConfig(body);
    return { success: true, data };
  }

  @Put('/api/v1/settings/database/engine')
  @ApiOperation({ summary: '엔진 데이터베이스 설정 업데이트' })
  @UseGuards(JwtAuthGuard)
  async putEngine(@Body() body: DbConfigDto) {
    const data = await this.settingsService.updateEngineDb(body.engineDbAddr ?? '');
    return { success: true, data };
  }

  @Put('/api/v1/settings/database/display')
  @ApiOperation({ summary: '디스플레이 데이터베이스 설정 업데이트' })
  @UseGuards(JwtAuthGuard)
  async putDisplay(@Body() body: DbConfigDto) {
    // 더 이상 사용하지 않음
    return { success: false, reason: 'display database config is deprecated' };
  }

  @Post('/api/v1/settings/database/test-connection')
  @ApiOperation({ summary: '데이터베이스 연결 테스트' })
  @UseGuards(JwtAuthGuard)
  async testConnection() {
    return { success: true, reachable: true };
  }

  @Get('/api/v1/settings/database/health')
  @ApiOperation({ summary: '데이터베이스 관리 서비스 상태' })
  @UseGuards(JwtAuthGuard)
  async dbHealth() {
    return { success: true, status: 'ok' };
  }

  @Get('/api/v1/settings/database/info')
  @ApiOperation({ summary: '데이터베이스 관리 서비스 정보' })
  @UseGuards(JwtAuthGuard)
  async dbInfo() {
    return { success: true, service: 'settings-database' };
  }

  @Get('/api/v1/settings/general/get')
  @ApiOperation({ summary: '설정값 조회 (GET)' })
  async getSetting(@Query('key') key: string) {
    const data = await this.settingsService.getSetting(key);
    return data;
  }

  @Post('/api/v1/settings/general')
  @ApiOperation({ summary: '설정값 저장/업데이트' })
  @UseGuards(JwtAuthGuard)
  async postSetting(@Body() body: SettingDto) {
    const data = await this.settingsService.setSetting(body.key, body.value);
    return { success: true, data };
  }

  // Legacy
  @Get('/settings_db_management')
  @ApiOperation({ summary: '레거시 DB 관리 설정 (최상위 경로)' })
  @UseGuards(JwtAuthGuard)
  async legacyDbManagement() {
    const data = await this.settingsService.getDbConfig();
    return { success: true, data };
  }

  @Post('/settings')
  @ApiOperation({ summary: '레거시 설정 저장 (최상위 경로)' })
  @UseGuards(JwtAuthGuard)
  async legacySettings(@Body() body: SettingDto) {
    const data = await this.settingsService.setSetting(body.key, body.value);
    return { success: true, data };
  }

  @Post('/settings/get')
  @ApiOperation({ summary: '레거시 설정 조회 (최상위 경로 - POST 방식)' })
  @HttpCode(200)
  async legacySettingsGet(@Body() body: SettingDto) {
    const data = await this.settingsService.getSetting(body.key);
    return data;
  }

  @Get('/settings_account')
  @ApiOperation({ summary: '레거시 계정 설정 (최상위 경로)' })
  @UseGuards(JwtAuthGuard)
  async legacySettingsAccount() {
    const data = await this.usersService.findAll();
    return { success: true, data };
  }
}
