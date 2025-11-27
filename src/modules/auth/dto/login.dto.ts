import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: 'admin' })
  @IsString()
  @MaxLength(30)
  account!: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  passwd!: string;

  @ApiProperty({ example: 'password123', required: false, description: 'password 필드(alias)' })
  @IsOptional()
  @IsString()
  password?: string;
}
