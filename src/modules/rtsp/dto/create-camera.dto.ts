import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateCameraDto {
  @ApiProperty({ example: 'CAM-001' })
  @IsString()
  @MaxLength(50)
  tag!: string;

  @ApiProperty({ example: 'rtsp://...' })
  @IsString()
  rtspAddress!: string;

  @ApiProperty({ example: '/path/to/image.jpg', required: false })
  @IsOptional()
  @IsString()
  lastImagePath?: string;
}
