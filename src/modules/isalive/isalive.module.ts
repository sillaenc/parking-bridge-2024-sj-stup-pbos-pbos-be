import { Module } from '@nestjs/common';
import { IsaliveController } from './isalive.controller';

@Module({
  controllers: [IsaliveController],
})
export class IsaliveModule {}
