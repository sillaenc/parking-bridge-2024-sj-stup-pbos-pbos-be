import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsString } from 'class-validator';

export class UpsertPingDto {
  @ApiProperty({ example: 'db' })
  @IsString()
  name!: string;

  @ApiProperty({ example: 'http://localhost:8080' })
  @IsString()
  address!: string;

  @ApiProperty({ example: true })
  @IsBoolean()
  isalright!: boolean;
}
