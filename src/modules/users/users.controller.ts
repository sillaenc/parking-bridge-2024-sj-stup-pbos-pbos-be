import {
  Body,
  Controller,
  Delete,
  Get,
  NotFoundException,
  Param,
  Post,
  Put,
  UseGuards,
  UsePipes,
} from '@nestjs/common';
import { ApiBody, ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateUserDto } from './dto/create-user.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { UpdateActivationDto } from './dto/update-activation.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';
import { UsersService } from './users.service';
import { ValidationPipe } from '@nestjs/common';

@ApiTags('users')
@Controller('api/v1/users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: '사용자 목록' })
  async getUsers() {
    const users = await this.usersService.findAll();
    return { success: true, data: users };
  }

  @Get(':account')
  @ApiOperation({ summary: '계정으로 사용자 조회' })
  @ApiParam({ name: 'account', example: 'admin' })
  async getUser(@Param('account') account: string) {
    const user = await this.usersService.findByAccount(account);
    if (!user) {
      throw new NotFoundException(`User not found: ${account}`);
    }
    return { success: true, data: user };
  }

  @Post()
  @ApiOperation({ summary: '사용자 생성' })
  @ApiBody({
    type: CreateUserDto,
    examples: {
      default: {
        value: {
          account: 'admin',
          passwd: 'password123',
          username: '관리자',
          userlevel: 1,
          isActivated: true,
        },
      },
    },
  })
  @UsePipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false, // passwdCheck 등 추가 필드 허용
      transform: true,
    }),
  )
  async createUser(@Body() body: CreateUserDto) {
    const user = await this.usersService.create(body);
    return { success: true, data: user };
  }

  @Put(':account/password')
  @ApiOperation({ summary: '비밀번호 변경' })
  @ApiParam({ name: 'account', example: 'admin' })
  @ApiBody({
    type: UpdatePasswordDto,
    examples: {
      default: { value: { oldPassword: 'old-pass', newPassword: 'new-pass' } },
    },
  })
  async changePassword(
    @Param('account') account: string,
    @Body() body: UpdatePasswordDto,
  ) {
    const result = await this.usersService.updatePassword(
      account,
      body.oldPassword,
      body.newPassword,
    );
    return { success: true, data: result };
  }

  @UseGuards(JwtAuthGuard)
  @Put(':account/activation')
  @ApiOperation({ summary: '활성/비활성 설정' })
  @ApiParam({ name: 'account', example: 'admin' })
  @ApiBody({
    type: UpdateActivationDto,
    examples: { default: { value: { isActivated: true } } },
  })
  async changeActivation(
    @Param('account') account: string,
    @Body() body: UpdateActivationDto,
  ) {
    const user = await this.usersService.updateActivation(account, body.isActivated);
    return { success: true, data: user };
  }

  @UseGuards(JwtAuthGuard)
  @Put(':account/reset')
  @ApiOperation({ summary: '비밀번호 초기화(관리자용)' })
  @ApiParam({ name: 'account', example: 'admin' })
  @ApiBody({
    type: ResetPasswordDto,
    examples: { default: { value: { newPassword: 'new-password', note: '관리자 초기화' } } },
  })
  async resetPassword(@Param('account') account: string, @Body() body: ResetPasswordDto) {
    const data = await this.usersService.resetPassword(account, body);
    return { success: true, data };
  }
}
