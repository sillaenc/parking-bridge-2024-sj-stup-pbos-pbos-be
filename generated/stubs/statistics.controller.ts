import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('statistics')
@Controller()
export class StatisticsStubController {
  @Get('/api/v1/statistics/daily')
  @ApiOperation({ summary: '일별 통계 조회' })
  async get_statistics_daily() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/daily', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/weekly')
  @ApiOperation({ summary: '주별 통계 조회' })
  async get_statistics_weekly() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/weekly', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/monthly')
  @ApiOperation({ summary: '월별 통계 조회' })
  async get_statistics_monthly() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/monthly', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/yearly')
  @ApiOperation({ summary: '연별 통계 조회' })
  async get_statistics_yearly() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/yearly', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/daily/all')
  @ApiOperation({ summary: '모든 일별 통계 조회' })
  async get_statistics_daily_all() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/daily/all', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/monthly/all')
  @ApiOperation({ summary: '모든 월별 통계 조회' })
  async get_statistics_monthly_all() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/monthly/all', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/yearly/all')
  @ApiOperation({ summary: '모든 연별 통계 조회' })
  async get_statistics_yearly_all() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/yearly/all', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/several-years')
  @ApiOperation({ summary: '여러 해 통계 조회' })
  async get_statistics_several_years() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/several-years', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/several-years/all')
  @ApiOperation({ summary: '모든 여러 해 통계 조회' })
  async get_statistics_several_years_all() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/several-years/all', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/statistics/custom-period')
  @ApiOperation({ summary: '사용자 정의 기간 통계 조회' })
  async post_statistics_custom_period() {
    throw new HttpException('Not implemented: POST /api/v1/statistics/custom-period', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/statistics/graph')
  @ApiOperation({ summary: '그래프용 통계 데이터 조회' })
  async post_statistics_graph() {
    throw new HttpException('Not implemented: POST /api/v1/statistics/graph', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/health')
  @ApiOperation({ summary: '통계 서비스 상태 확인' })
  async get_statistics_health() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/statistics/info')
  @ApiOperation({ summary: '통계 서비스 정보 조회' })
  async get_statistics_info() {
    throw new HttpException('Not implemented: GET /api/v1/statistics/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/statistics_cam_parking_area')
  @ApiOperation({ summary: '레거시 카메라 주차 통계 (최상위 경로)' })
  async post_statistics_cam_parking_area() {
    throw new HttpException('Not implemented: POST /statistics_cam_parking_area', HttpStatus.NOT_IMPLEMENTED);
  }

}