import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ParkingModule } from './modules/parking/parking.module';
import { StatsModule } from './modules/stats/stats.module';
import { FilesModule } from './modules/files/files.module';
import { RtspModule } from './modules/rtsp/rtsp.module';
import { SystemModule } from './modules/system/system.module';
import { ResourcesModule } from './modules/resources/resources.module';
import { MonitoringModule } from './modules/monitoring/monitoring.module';
import { VehicleModule } from './modules/vehicle/vehicle.module';
import { CentralModule } from './modules/central/central.module';
import { BaseInfoModule } from './modules/base-info/base-info.module';
import { SettingsModule } from './modules/settings/settings.module';
import { UtilitiesModule } from './modules/utilities/utilities.module';
import { EngineModule } from './modules/engine/engine.module';
import { ElectricSignsModule } from './modules/electric-signs/electric-signs.module';
import { DisplayModule } from './modules/display/display.module';
import { BillboardModule } from './modules/billboard/billboard.module';
import { CamerasModule } from './modules/cameras/cameras.module';
import { LedModule } from './modules/led/led.module';
import { CameraParkingModule } from './modules/camera-parking/camera-parking.module';
import { ScheduleModule } from '@nestjs/schedule';
import { PrismaModule } from './prisma/prisma.module';
import { FirstSettingService } from './modules/initialization/first-setting.service';
import { IsaliveModule } from './modules/isalive/isalive.module';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    AuthModule,
    UsersModule,
    ParkingModule,
    StatsModule,
    FilesModule,
    RtspModule,
    SystemModule,
    ResourcesModule,
    MonitoringModule,
    VehicleModule,
    CentralModule,
    BaseInfoModule,
    SettingsModule,
    UtilitiesModule,
    EngineModule,
    ElectricSignsModule,
    DisplayModule,
    BillboardModule,
    CamerasModule,
    LedModule,
    CameraParkingModule,
    IsaliveModule,
  ],
  providers: [FirstSettingService],
})
export class AppModule {}
