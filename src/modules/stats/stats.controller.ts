import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBody, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { StatsRangeDto } from './dto/stats-range.dto';
import { GraphRangeDto } from './dto/graph-range.dto';
import { StatsService } from './stats.service';

@ApiTags('statistics')
@Controller('api/v1/statistics')
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  @Get('daily')
  @ApiOperation({ summary: '일별 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async daily(@Query() query: StatsRangeDto) {
    const data = await this.statsService.daily(
      query.start ? new Date(query.start) : undefined,
      query.end ? new Date(query.end) : undefined,
    );
    return { success: true, data };
  }

  @Get('weekly')
  @ApiOperation({ summary: '주별 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async weekly() {
    const data = await this.statsService.weekly();
    return { success: true, data };
  }

  @Get('monthly')
  @ApiOperation({ summary: '월별 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async monthly() {
    const data = await this.statsService.monthly();
    return { success: true, data };
  }

  @Get('yearly')
  @ApiOperation({ summary: '연별 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async yearly() {
    const data = await this.statsService.yearly();
    return { success: true, data };
  }

  @Get('daily/all')
  @ApiOperation({ summary: '모든 일별 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async dailyAll() {
    const data = await this.statsService.dailyAll();
    return { success: true, data };
  }

  @Get('monthly/all')
  @ApiOperation({ summary: '모든 월별 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async monthlyAll() {
    const data = await this.statsService.monthlyAll();
    return { success: true, data };
  }

  @Get('yearly/all')
  @ApiOperation({ summary: '모든 연별 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async yearlyAll() {
    const data = await this.statsService.yearlyAll();
    return { success: true, data };
  }

  @Get('several-years')
  @ApiOperation({ summary: '여러 해 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async severalYears(@Query() query: StatsRangeDto) {
    const data = await this.statsService.perYearRange(query);
    return { success: true, data };
  }

  @Get('several-years/all')
  @ApiOperation({ summary: '모든 여러 해 통계 조회' })
  @UseGuards(JwtAuthGuard)
  async severalYearsAll() {
    const data = await this.statsService.yearlyAll();
    return { success: true, data };
  }

  @Post('custom-period')
  @ApiOperation({ summary: '사용자 정의 기간 통계 조회' })
  async customPeriod(@Body() body: StatsRangeDto) {
    const data = await this.statsService.perDayRange(body);
    return { success: true, data };
  }

  @Post('graph')
  @ApiOperation({ summary: '그래프용 통계 데이터 조회' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        startDay: { type: 'string', example: '2025-11-04' },
        endDay: { type: 'string', example: '2025-11-05' },
      },
      required: ['startDay', 'endDay'],
    },
  })
  async graph(@Body() body: GraphRangeDto) {
    const data = await this.statsService.graphRange(body);
    return { success: true, data };
  }

  @Get('health')
  @ApiOperation({ summary: '통계 서비스 상태 확인' })
  @UseGuards(JwtAuthGuard)
  async health() {
    return { success: true, status: 'ok' };
  }

  @Get('info')
  @ApiOperation({ summary: '통계 서비스 정보 조회' })
  @UseGuards(JwtAuthGuard)
  async info() {
    return { success: true, service: 'statistics' };
  }

  // Legacy top-level route
  @Post('/statistics_cam_parking_area')
  @ApiOperation({ summary: '레거시 카메라 주차 통계 (최상위 경로)' })
  @UseGuards(JwtAuthGuard)
  async legacyCamParkingArea(@Body() body: any) {
    const data = await this.statsService.perDayRange({
      start: body?.startDay,
      end: body?.endDay,
    } as StatsRangeDto);
    return { success: true, data };
  }
}
