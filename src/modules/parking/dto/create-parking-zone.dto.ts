import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateParkingZoneDto {
  @ApiProperty({ example: 'B1', description: '주차 구역 이름' })
  @IsString()
  @MaxLength(50)
  parkingName!: string;

  @ApiProperty({ example: '/file/address/path', description: '파일 경로' })
  @IsString()
  fileAddress!: string;

  @ApiProperty({ example: 'B1', required: false, description: '층 정보' })
  @IsOptional()
  @IsString()
  floor?: string;
}
