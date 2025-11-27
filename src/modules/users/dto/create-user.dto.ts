import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsBoolean, IsInt, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateUserDto {
  @ApiProperty({ example: 'admin', description: '계정 ID' })
  @IsString()
  @MaxLength(30)
  account!: string;

  @ApiProperty({ example: 'password123', description: '비밀번호(평문, 나중에 해싱 권장)' })
  @IsString()
  passwd!: string;

  @ApiProperty({ example: 'password123', required: false, description: '비밀번호 확인(무시됨)' })
  @IsOptional()
  @IsString()
  passwdCheck?: string;

  @ApiProperty({ example: '관리자', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  username?: string;

  @ApiProperty({ example: 1, description: '권한 레벨', required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  userlevel?: number = 0;

  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  isActivated?: boolean = true;
}
