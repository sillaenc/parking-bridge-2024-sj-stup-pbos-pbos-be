import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsString, MaxLength } from 'class-validator';

export class ChangeLotTypeDto {
  @ApiProperty({ example: 'F1_A08_3_N024' })
  @IsString()
  @MaxLength(50)
  tag!: string;

  @ApiProperty({ example: 'F1_A08_3_L099' })
  @IsString()
  @MaxLength(50)
  changed_tag!: string;

  @ApiProperty({ example: 3 })
  @IsInt()
  lot_type!: number;
}
