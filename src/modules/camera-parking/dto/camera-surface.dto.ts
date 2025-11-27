import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, MaxLength } from 'class-validator';

export class CameraSurfaceDto {
  @ApiProperty({ example: 1, required: false })
  @IsOptional()
  @IsInt()
  uid?: number;

  @ApiProperty({ example: 'TAG-001' })
  @IsString()
  @MaxLength(50)
  tag!: string;

  @ApiProperty({ example: 'ENG001' })
  @IsString()
  @MaxLength(10)
  engine_code!: string;

  @ApiProperty({ example: '/uri/path' })
  @IsString()
  uri!: string;
}
