import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('auth')
@Controller()
export class AuthStubController {
  @Post('/api/v1/auth/login')
  @ApiOperation({ summary: '사용자 로그인' })
  async post_auth_login() {
    throw new HttpException('Not implemented: POST /api/v1/auth/login', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/base-info')
  @ApiOperation({ summary: '기본 정보 조회' })
  async get_auth_base_info() {
    throw new HttpException('Not implemented: GET /api/v1/auth/base-info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/token')
  @ApiOperation({ summary: '토큰 정보 조회' })
  async get_auth_token() {
    throw new HttpException('Not implemented: GET /api/v1/auth/token', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/protected')
  @ApiOperation({ summary: '보호된 엔드포인트 테스트' })
  async get_auth_protected() {
    throw new HttpException('Not implemented: GET /api/v1/auth/protected', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/auth/refresh')
  @ApiOperation({ summary: '토큰 갱신' })
  async post_auth_refresh() {
    throw new HttpException('Not implemented: POST /api/v1/auth/refresh', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/health')
  @ApiOperation({ summary: '인증 서비스 상태 확인' })
  async get_auth_health() {
    throw new HttpException('Not implemented: GET /api/v1/auth/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/info')
  @ApiOperation({ summary: '인증 서비스 정보' })
  async get_auth_info() {
    throw new HttpException('Not implemented: GET /api/v1/auth/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/accounts/check')
  @ApiOperation({ summary: '계정 목록 확인' })
  async get_auth_accounts_check() {
    throw new HttpException('Not implemented: GET /api/v1/auth/accounts/check', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/auth/legacy')
  @ApiOperation({ summary: '레거시 로그인 (기존 클라이언트 호환)' })
  async post_auth_legacy() {
    throw new HttpException('Not implemented: POST /api/v1/auth/legacy', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/legacy/base')
  @ApiOperation({ summary: '레거시 기본 정보 조회' })
  async get_auth_legacy_base() {
    throw new HttpException('Not implemented: GET /api/v1/auth/legacy/base', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/legacy/jwt')
  @ApiOperation({ summary: '레거시 JWT 토큰 조회' })
  async get_auth_legacy_jwt() {
    throw new HttpException('Not implemented: GET /api/v1/auth/legacy/jwt', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/legacy/protected')
  @ApiOperation({ summary: '레거시 보호된 리소스 접근 테스트' })
  async get_auth_legacy_protected() {
    throw new HttpException('Not implemented: GET /api/v1/auth/legacy/protected', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/status')
  @ApiOperation({ summary: '로그인 상태 및 기본 정보 조회' })
  async get_auth_status() {
    throw new HttpException('Not implemented: GET /api/v1/auth/status', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/auth/status/profile')
  @ApiOperation({ summary: '사용자 프로필 조회' })
  async post_auth_status_profile() {
    throw new HttpException('Not implemented: POST /api/v1/auth/status/profile', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/confirm_account_list')
  @ApiOperation({ summary: '레거시 계정 목록 확인 (최상위 경로)' })
  async get_confirm_account_list() {
    throw new HttpException('Not implemented: GET /confirm_account_list', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/parking_status')
  @ApiOperation({ summary: '레거시 주차 상태 조회 (최상위 경로)' })
  async get_parking_status() {
    throw new HttpException('Not implemented: GET /parking_status', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/login_setting')
  @ApiOperation({ summary: '레거시 로그인 설정 (최상위 경로)' })
  async post_login_setting() {
    throw new HttpException('Not implemented: POST /login_setting', HttpStatus.NOT_IMPLEMENTED);
  }

}