import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateBaseInfoDto {
  @ApiProperty({ example: '스마트파킹 주차장' })
  @IsString()
  name!: string;

  @ApiProperty({ example: '서울시 강남구 ...' })
  @IsString()
  address!: string;

  @ApiProperty({ example: '37.12345', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  latitude?: string;

  @ApiProperty({ example: '127.12345', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  longitude?: string;

  @ApiProperty({ example: '홍길동' })
  @IsString()
  manager!: string;

  @ApiProperty({ example: '010-1234-5678' })
  @IsString()
  @MaxLength(30)
  phoneNumber!: string;
}
