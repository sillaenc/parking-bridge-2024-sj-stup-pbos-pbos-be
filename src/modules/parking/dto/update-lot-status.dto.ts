import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class UpdateLotStatusDto {
  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @IsBoolean()
  isUsed?: boolean;

  @ApiProperty({ example: '12가3456', required: false })
  @IsOptional()
  @IsString()
  plate?: string;

  @ApiProperty({ example: '2025-01-01T12:00:00Z', required: false })
  @IsOptional()
  @IsString()
  startTime?: string;
}
