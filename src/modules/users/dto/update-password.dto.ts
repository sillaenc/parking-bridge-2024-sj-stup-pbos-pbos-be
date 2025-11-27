import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength } from 'class-validator';

export class UpdatePasswordDto {
  @ApiProperty({ example: 'old-pass' })
  @IsString()
  oldPassword!: string;

  @ApiProperty({ example: 'new-pass' })
  @IsString()
  @MaxLength(100)
  newPassword!: string;
}
