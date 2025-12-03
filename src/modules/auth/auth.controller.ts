import { Body, Controller, HttpCode, Post, ValidationPipe, Get } from '@nestjs/common';
import { ApiOperation, ApiTags, ApiBody } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { BaseInfoService } from '../base-info/base-info.service';

@ApiTags('auth')
@Controller('api/v1/auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly baseInfoService: BaseInfoService,
  ) {}

  @Post('login')
  @HttpCode(200)
  @ApiOperation({ summary: '로그인(JWT 발급)' })
  @ApiBody({
    type: LoginDto,
    examples: {
      default: {
        value: { account: 'admin', passwd: 'password123' },
      },
    },
  })
  async login(
    @Body(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: false, // password 필드 alias 허용
        transform: true,
      }),
    )
    body: LoginDto,
  ) {
    const result = await this.authService.login(body);
    return { success: true, message: 'Login successful', data: result };
  }

  @Get('base-info')
  @HttpCode(200)
  @ApiOperation({ summary: '기본 정보 조회' })
  async baseInfo() {
    const data = await this.baseInfoService.getAuthBasePayload();
    return { success: true, message: 'Base information retrieved successfully', data };
  }
}
