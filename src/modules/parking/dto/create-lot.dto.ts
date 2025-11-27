import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsInt, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateLotDto {
  @ApiProperty({ example: 'A01', description: '태그(고유)' })
  @IsString()
  @MaxLength(10)
  tag!: string;

  @ApiProperty({ example: 1, description: 'lot_type FK', required: false })
  @IsOptional()
  @IsInt()
  lotTypeId?: number;

  @ApiProperty({ example: 'POINT-001', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  point?: string;

  @ApiProperty({ example: 'B1', required: false })
  @IsOptional()
  @IsString()
  floor?: string;

  @ApiProperty({ example: 'car-asset', required: false })
  @IsOptional()
  @IsString()
  asset?: string;

  @ApiProperty({ example: '12가3456', required: false })
  @IsOptional()
  @IsString()
  plate?: string;

  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @IsBoolean()
  isUsed?: boolean;

  @ApiProperty({ example: '2025-01-01T12:00:00Z', required: false })
  @IsOptional()
  @IsString()
  startTime?: string;
}
