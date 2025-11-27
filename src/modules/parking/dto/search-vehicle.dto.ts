import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class SearchVehicleDto {
  @ApiProperty({ example: 'A01', required: false })
  @IsOptional()
  @IsString()
  tag?: string;

  @ApiProperty({ example: '12가', required: false, description: '번호판 like 검색' })
  @IsOptional()
  @IsString()
  plate?: string;
}
