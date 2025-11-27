import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put } from '@nestjs/common';

@ApiTags('auth')
@Controller()
export class AuthStubController {
  @Post('/api/v1/auth/login')
  @ApiOperation({ summary: '사용자 로그인' })
  async post_api_v1_auth_login() {
    throw new HttpException('Not implemented: POST /api/v1/auth/login', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/base-info')
  @ApiOperation({ summary: '기본 정보 조회' })
  async get_api_v1_auth_base_info() {
    throw new HttpException('Not implemented: GET /api/v1/auth/base-info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/token')
  @ApiOperation({ summary: '토큰 정보 조회' })
  async get_api_v1_auth_token() {
    throw new HttpException('Not implemented: GET /api/v1/auth/token', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/protected')
  @ApiOperation({ summary: '보호된 엔드포인트 테스트' })
  async get_api_v1_auth_protected() {
    throw new HttpException('Not implemented: GET /api/v1/auth/protected', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/auth/refresh')
  @ApiOperation({ summary: '토큰 갱신' })
  async post_api_v1_auth_refresh() {
    throw new HttpException('Not implemented: POST /api/v1/auth/refresh', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/auth/register')
  @ApiOperation({ summary: '사용자 회원가입' })
  async post_api_v1_auth_register() {
    throw new HttpException('Not implemented: POST /api/v1/auth/register', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/auth/register/legacy')
  @ApiOperation({ summary: '레거시 사용자 회원가입' })
  async post_api_v1_auth_register_legacy() {
    throw new HttpException(
      'Not implemented: POST /api/v1/auth/register/legacy',
      HttpStatus.NOT_IMPLEMENTED,
    );
  }

  @Post('/api/v1/auth/logout')
  @ApiOperation({ summary: '로그아웃' })
  async post_api_v1_auth_logout() {
    throw new HttpException('Not implemented: POST /api/v1/auth/logout', HttpStatus.NOT_IMPLEMENTED);
  }

  @Put('/api/v1/auth/reset')
  @ApiOperation({ summary: '계정 초기화' })
  async put_api_v1_auth_reset() {
    throw new HttpException('Not implemented: PUT /api/v1/auth/reset', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/auth/status')
  @ApiOperation({ summary: '인증 상태 확인' })
  async get_api_v1_auth_status() {
    throw new HttpException('Not implemented: GET /api/v1/auth/status', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/auth/login/legacy')
  @ApiOperation({ summary: '레거시 로그인' })
  async post_api_v1_auth_login_legacy() {
    throw new HttpException(
      'Not implemented: POST /api/v1/auth/login/legacy',
      HttpStatus.NOT_IMPLEMENTED,
    );
  }

  @Get('/api/v1/auth/base-info/legacy')
  @ApiOperation({ summary: '레거시 기본 정보 조회' })
  async get_api_v1_auth_base_info_legacy() {
    throw new HttpException(
      'Not implemented: GET /api/v1/auth/base-info/legacy',
      HttpStatus.NOT_IMPLEMENTED,
    );
  }

  @Get('/api/v1/auth/token/legacy')
  @ApiOperation({ summary: '레거시 토큰 정보 조회' })
  async get_api_v1_auth_token_legacy() {
    throw new HttpException(
      'Not implemented: GET /api/v1/auth/token/legacy',
      HttpStatus.NOT_IMPLEMENTED,
    );
  }

  @Get('/api/v1/auth/protected/legacy')
  @ApiOperation({ summary: '레거시 보호된 엔드포인트 테스트' })
  async get_api_v1_auth_protected_legacy() {
    throw new HttpException(
      'Not implemented: GET /api/v1/auth/protected/legacy',
      HttpStatus.NOT_IMPLEMENTED,
    );
  }

  @Post('/api/v1/auth/refresh/legacy')
  @ApiOperation({ summary: '레거시 토큰 갱신' })
  async post_api_v1_auth_refresh_legacy() {
    throw new HttpException(
      'Not implemented: POST /api/v1/auth/refresh/legacy',
      HttpStatus.NOT_IMPLEMENTED,
    );
  }

  @Post('/api/v1/auth/logout/legacy')
  @ApiOperation({ summary: '레거시 로그아웃' })
  async post_api_v1_auth_logout_legacy() {
    throw new HttpException(
      'Not implemented: POST /api/v1/auth/logout/legacy',
      HttpStatus.NOT_IMPLEMENTED,
    );
  }
}
