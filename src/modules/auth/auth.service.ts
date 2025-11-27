import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import * as crypto from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async validateUser(account: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: { account },
    });
    if (!user) return null;

    const sha256 = (v: string) => crypto.createHash('sha256').update(v).digest('hex');

    // 1) bcrypt 비교
    const bcryptValid = await bcrypt.compare(password, user.passwd).catch(() => false);
    // 2) 평문 비교(legacy 호환)
    const plainValid = user.passwd === password;
    // 3) double SHA256 비교(legacy create_admin.dart 호환)
    const doubleShaValid = user.passwd === sha256(sha256(password));

    const valid = bcryptValid || plainValid || doubleShaValid;
    if (!valid) return null;

    return user;
  }

  async login(body: LoginDto) {
    const password = body.passwd ?? body.password ?? '';
    const user = await this.validateUser(body.account, password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    if (user.isActivated === false) {
      throw new UnauthorizedException('User is deactivated');
    }

    const payload = { sub: user.id, account: user.account, level: user.userlevel };
    const accessToken = await this.jwtService.signAsync(payload);

    return {
      uid: user.id,
      account: user.account,
      username: user.username,
      userlevel: user.userlevel,
      isActivated: user.isActivated,
      token: accessToken,
    };
  }
}
