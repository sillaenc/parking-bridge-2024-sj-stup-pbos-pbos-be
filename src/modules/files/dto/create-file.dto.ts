import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateFileDto {
  @ApiProperty({ example: 'file-123.jpg' })
  @IsString()
  @MaxLength(255)
  filename!: string;

  @ApiProperty({ example: 'original-name.jpg', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  originalFilename?: string;

  @ApiProperty({ example: '/files/file-123.jpg' })
  @IsString()
  filePath!: string;

  @ApiProperty({ example: 'jpg', required: false })
  @IsOptional()
  @IsString()
  fileType?: string;

  @ApiProperty({ example: 'image', required: false })
  @IsOptional()
  @IsString()
  fileCategory?: string;

  @ApiProperty({ example: 102400, required: false })
  @IsOptional()
  @IsInt()
  fileSize?: number;

  @ApiProperty({ example: 'image/jpeg', required: false })
  @IsOptional()
  @IsString()
  mimeType?: string;

  @ApiProperty({ example: '테스트 파일', required: false })
  @IsOptional()
  @IsString()
  description?: string;
}
