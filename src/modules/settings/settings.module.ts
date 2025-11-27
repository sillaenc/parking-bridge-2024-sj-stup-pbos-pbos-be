import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { SettingsController } from './settings.controller';
import { SettingsService } from './settings.service';
import { UsersModule } from '../users/users.module';
import { UsersService } from '../users/users.service';

@Module({
  imports: [PrismaModule, UsersModule],
  controllers: [SettingsController],
  providers: [SettingsService, UsersService],
})
export class SettingsModule {}
