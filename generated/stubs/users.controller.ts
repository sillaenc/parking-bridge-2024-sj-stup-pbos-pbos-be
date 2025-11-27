import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('users')
@Controller()
export class UsersStubController {
  @Get('/api/v1/users')
  @ApiOperation({ summary: '모든 사용자 조회' })
  async get_users() {
    throw new HttpException('Not implemented: GET /api/v1/users', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/users')
  @ApiOperation({ summary: '새 사용자 생성' })
  async post_users() {
    throw new HttpException('Not implemented: POST /api/v1/users', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/users/{account}')
  @ApiOperation({ summary: '특정 사용자 조회' })
  async get_users_account() {
    throw new HttpException('Not implemented: GET /api/v1/users/{account}', HttpStatus.NOT_IMPLEMENTED);
  }

  @Put('/api/v1/users/{account}')
  @ApiOperation({ summary: '사용자 정보 수정' })
  async put_users_account() {
    throw new HttpException('Not implemented: PUT /api/v1/users/{account}', HttpStatus.NOT_IMPLEMENTED);
  }

  @Delete('/api/v1/users/{account}')
  @ApiOperation({ summary: '사용자 삭제' })
  async delete_users_account() {
    throw new HttpException('Not implemented: DELETE /api/v1/users/{account}', HttpStatus.NOT_IMPLEMENTED);
  }

  @Patch('/api/v1/users/{account}/password')
  @ApiOperation({ summary: '비밀번호 변경' })
  async patch_users_account_password() {
    throw new HttpException('Not implemented: PATCH /api/v1/users/{account}/password', HttpStatus.NOT_IMPLEMENTED);
  }

  @Patch('/api/v1/users/{account}/password/reset')
  @ApiOperation({ summary: '비밀번호 초기화' })
  async patch_users_account_password_reset() {
    throw new HttpException('Not implemented: PATCH /api/v1/users/{account}/password/reset', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/users/health')
  @ApiOperation({ summary: '사용자 관리 서비스 상태' })
  async get_users_health() {
    throw new HttpException('Not implemented: GET /api/v1/users/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/users/info')
  @ApiOperation({ summary: '사용자 관리 서비스 정보' })
  async get_users_info() {
    throw new HttpException('Not implemented: GET /api/v1/users/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/users/legacy')
  @ApiOperation({ summary: '레거시 사용자 목록 조회' })
  async get_users_legacy() {
    throw new HttpException('Not implemented: GET /api/v1/users/legacy', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/users/legacy')
  @ApiOperation({ summary: '레거시 사용자 생성/업데이트 (통합)' })
  async post_users_legacy() {
    throw new HttpException('Not implemented: POST /api/v1/users/legacy', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/users/legacy/updateUser')
  @ApiOperation({ summary: '레거시 사용자 정보 수정' })
  async post_users_legacy_updateUser() {
    throw new HttpException('Not implemented: POST /api/v1/users/legacy/updateUser', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/users/legacy/changePassword')
  @ApiOperation({ summary: '레거시 비밀번호 변경' })
  async post_users_legacy_changePassword() {
    throw new HttpException('Not implemented: POST /api/v1/users/legacy/changePassword', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/users/legacy/resetPassword')
  @ApiOperation({ summary: '레거시 비밀번호 리셋' })
  async post_users_legacy_resetPassword() {
    throw new HttpException('Not implemented: POST /api/v1/users/legacy/resetPassword', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/users/legacy/insertUser')
  @ApiOperation({ summary: '레거시 사용자 삽입' })
  async post_users_legacy_insertUser() {
    throw new HttpException('Not implemented: POST /api/v1/users/legacy/insertUser', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/users/legacy/deleteUser')
  @ApiOperation({ summary: '레거시 사용자 삭제' })
  async post_users_legacy_deleteUser() {
    throw new HttpException('Not implemented: POST /api/v1/users/legacy/deleteUser', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/users/admin')
  @ApiOperation({ summary: '관리자 계정 생성' })
  async post_users_admin() {
    throw new HttpException('Not implemented: POST /api/v1/users/admin', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/create_admin')
  @ApiOperation({ summary: '레거시 관리자 생성 (최상위 경로)' })
  async post_create_admin() {
    throw new HttpException('Not implemented: POST /create_admin', HttpStatus.NOT_IMPLEMENTED);
  }

}