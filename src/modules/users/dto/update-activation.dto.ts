import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean } from 'class-validator';

export class UpdateActivationDto {
  @ApiProperty({ example: true })
  @IsBoolean()
  isActivated!: boolean;
}
