import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class ResetPasswordDto {
  @ApiProperty({ example: 'new-password' })
  @IsString()
  @MaxLength(100)
  newPassword!: string;

  @ApiProperty({ example: '관리자 비밀번호 초기화', required: false })
  @IsOptional()
  @IsString()
  note?: string;
}
