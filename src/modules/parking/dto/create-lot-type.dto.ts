import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateLotTypeDto {
  @ApiProperty({ example: 'N' })
  @IsString()
  @MaxLength(30)
  lotType!: string;

  @ApiProperty({ example: '일반', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  tag?: string;

  @ApiProperty({ example: 'N000', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(5)
  codeFormat?: string;

  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @IsBoolean()
  isUsed?: boolean;
}
