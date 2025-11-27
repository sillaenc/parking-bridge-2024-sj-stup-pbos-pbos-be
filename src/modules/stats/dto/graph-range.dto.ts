import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString } from 'class-validator';

export class GraphRangeDto {
  @ApiProperty({ example: 'B1', required: false })
  @IsOptional()
  @IsString()
  floor?: string;

  @ApiProperty({ example: 1, required: false, description: 'lot_type FK' })
  @IsOptional()
  @IsInt()
  lotTypeId?: number;

  @ApiProperty({ example: '2025-01-01T00:00:00Z' })
  @IsString()
  start!: string;

  @ApiProperty({ example: '2025-01-02T00:00:00Z' })
  @IsString()
  end!: string;
}
