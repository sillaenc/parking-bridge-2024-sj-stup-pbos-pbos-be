import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, MaxLength } from 'class-validator';

export class LinkZoneFileDto {
  @ApiProperty({ example: 1 })
  @IsInt()
  parkingZoneId!: number;

  @ApiProperty({ example: 10 })
  @IsInt()
  fileId!: number;

  @ApiProperty({ example: 'guide', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  filePurpose?: string;
}
