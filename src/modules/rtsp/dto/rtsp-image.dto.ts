import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class RtspImageDto {
  @ApiProperty({ description: 'Base64 인코딩된 이미지', required: false })
  @IsOptional()
  @IsString()
  image_base64?: string;

  @ApiProperty({ description: '이미지 경로 직접 지정', required: false })
  @IsOptional()
  @IsString()
  image_path?: string;
}
