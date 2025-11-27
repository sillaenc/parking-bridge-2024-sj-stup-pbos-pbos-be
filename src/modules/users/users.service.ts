import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import * as crypto from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  private doubleSha(value: string) {
    const sha = (v: string) => crypto.createHash('sha256').update(v).digest('hex');
    return sha(sha(value));
  }

  async findAll() {
    return this.prisma.user.findMany({
      select: {
        id: true,
        account: true,
        username: true,
        userlevel: true,
        isActivated: true,
      },
      orderBy: { id: 'asc' },
    });
  }

  async findByAccount(account: string) {
    return this.prisma.user.findUnique({
      where: { account },
      select: {
        id: true,
        account: true,
        username: true,
        userlevel: true,
        isActivated: true,
      },
    });
  }

  async create(dto: CreateUserDto) {
    // pbos_be_v2 create_admin.dart와 동일: double SHA256
    const hashed = this.doubleSha(dto.passwd);
    const user = await this.prisma.user.create({
      data: {
        account: dto.account,
        passwd: hashed,
        username: dto.username,
        userlevel: dto.userlevel ?? 0,
        isActivated: dto.isActivated ?? true,
      },
      select: {
        id: true,
        account: true,
        username: true,
        userlevel: true,
        isActivated: true,
      },
    });
    return user;
  }

  async updatePassword(account: string, oldPassword: string, newPassword: string) {
    const user = await this.prisma.user.findUnique({ where: { account } });
    if (!user) {
      throw new Error('User not found');
    }
    const oldHash = this.doubleSha(oldPassword);
    const validBcrypt = await bcrypt.compare(oldPassword, user.passwd).catch(() => false);
    const validDoubleSha = user.passwd === oldHash;
    if (!validBcrypt && !validDoubleSha && user.passwd !== oldPassword) {
      throw new Error('Invalid password');
    }
    const hashed = this.doubleSha(newPassword);
    await this.prisma.user.update({
      where: { account },
      data: { passwd: hashed },
    });
    return { account, updated: true };
  }

  async resetPassword(account: string, dto: ResetPasswordDto) {
    const user = await this.prisma.user.findUnique({ where: { account } });
    if (!user) {
      throw new Error('User not found');
    }
    const hashed = this.doubleSha(dto.newPassword);
    await this.prisma.user.update({
      where: { account },
      data: { passwd: hashed },
    });
    return { account, reset: true };
  }

  async updateActivation(account: string, isActivated: boolean) {
    const user = await this.prisma.user.update({
      where: { account },
      data: { isActivated },
      select: {
        id: true,
        account: true,
        username: true,
        userlevel: true,
        isActivated: true,
      },
    });
    return user;
  }
}
