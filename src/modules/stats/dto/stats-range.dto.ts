import { ApiProperty } from '@nestjs/swagger';
import { IsISO8601, IsOptional, IsString } from 'class-validator';

export class StatsRangeDto {
  @ApiProperty({ example: '2025-01-01', required: false, description: '레거시 startDay 호환' })
  @IsOptional()
  @IsString()
  startDay?: string;

  @ApiProperty({ example: '2025-01-31', required: false, description: '레거시 endDay 호환' })
  @IsOptional()
  @IsString()
  endDay?: string;

  @ApiProperty({ example: '2025-01-01T00:00:00Z', required: false })
  @IsOptional()
  @IsISO8601()
  start?: string;

  @ApiProperty({ example: '2025-01-31T23:59:59Z', required: false })
  @IsOptional()
  @IsISO8601()
  end?: string;
}
