import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class UpsertSettingDto {
  @ApiProperty({ example: 'machine_display' })
  @IsString()
  key!: string;

  @ApiProperty({ example: '안녕하세요', required: false })
  @IsOptional()
  @IsString()
  value?: string;
}
