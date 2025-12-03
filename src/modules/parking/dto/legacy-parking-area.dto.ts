import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class LegacyParkingAreaDto {
  @ApiProperty({ example: '지상1층.json' })
  @IsString()
  @MaxLength(255)
  parking_name!: string;

  @ApiProperty({ example: 'json_folder/지상1층.json' })
  @IsString()
  @MaxLength(255)
  file_address!: string;

  @ApiProperty({ example: 'F1', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  floor?: string;
}
