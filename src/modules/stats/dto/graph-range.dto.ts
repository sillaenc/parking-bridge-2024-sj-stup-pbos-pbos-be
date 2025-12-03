import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class GraphRangeDto {
  @ApiProperty({ example: '2025-11-04' })
  @IsString()
  startDay!: string;

  @ApiProperty({ example: '2025-11-05' })
  @IsString()
  endDay!: string;
}
