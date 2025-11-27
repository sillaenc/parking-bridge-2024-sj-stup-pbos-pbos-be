import { Controller, HttpException, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Get, Post, Put, Patch, Delete } from '@nestjs/common';

@ApiTags('utilities')
@Controller()
export class UtilitiesStubController {
  @Post('/graphData')
  @ApiOperation({ summary: '레거시 그래프 데이터 조회 (최상위 경로)' })
  async post_graphData() {
    throw new HttpException('Not implemented: POST /graphData', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/graphData/test')
  @ApiOperation({ summary: '그래프 데이터 테스트 엔드포인트 (최상위 경로)' })
  async get_graphData_test() {
    throw new HttpException('Not implemented: GET /graphData/test', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/resources')
  @ApiOperation({ summary: '주차장 리소스 조회' })
  async get_resources() {
    throw new HttpException('Not implemented: GET /api/v1/resources', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/resources/parking-lots')
  @ApiOperation({ summary: '주차 공간 목록 조회' })
  async get_resources_parking_lots() {
    throw new HttpException('Not implemented: GET /api/v1/resources/parking-lots', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/resources/parking-lots/raw')
  @ApiOperation({ summary: '주차 공간 원시 데이터 조회' })
  async get_resources_parking_lots_raw() {
    throw new HttpException('Not implemented: GET /api/v1/resources/parking-lots/raw', HttpStatus.NOT_IMPLEMENTED);
  }

  @Post('/api/v1/resources/refresh')
  @ApiOperation({ summary: '리소스 새로고침' })
  async post_resources_refresh() {
    throw new HttpException('Not implemented: POST /api/v1/resources/refresh', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/resources/status')
  @ApiOperation({ summary: '리소스 상태 조회' })
  async get_resources_status() {
    throw new HttpException('Not implemented: GET /api/v1/resources/status', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/resources/health')
  @ApiOperation({ summary: '리소스 관리 서비스 상태' })
  async get_resources_health() {
    throw new HttpException('Not implemented: GET /api/v1/resources/health', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api/v1/resources/info')
  @ApiOperation({ summary: '리소스 관리 서비스 정보' })
  async get_resources_info() {
    throw new HttpException('Not implemented: GET /api/v1/resources/info', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/get_resource')
  @ApiOperation({ summary: '레거시 리소스 조회 (최상위 경로)' })
  async get_get_resource() {
    throw new HttpException('Not implemented: GET /get_resource', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/docs')
  @ApiOperation({ summary: 'Swagger UI 문서 (기본)' })
  async get_docs() {
    throw new HttpException('Not implemented: GET /docs', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/swagger-ui.html')
  @ApiOperation({ summary: 'Swagger UI 문서 (대체 경로)' })
  async get_swagger_ui_html() {
    throw new HttpException('Not implemented: GET /swagger-ui.html', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/api-docs')
  @ApiOperation({ summary: 'API 문서 (대체 경로)' })
  async get_api_docs() {
    throw new HttpException('Not implemented: GET /api-docs', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/docs-complete')
  @ApiOperation({ summary: '완전한 Swagger UI 문서 (177개 API)' })
  async get_docs_complete() {
    throw new HttpException('Not implemented: GET /docs-complete', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/swagger.yaml')
  @ApiOperation({ summary: '기본 OpenAPI 스펙 (YAML)' })
  async get_swagger_yaml() {
    throw new HttpException('Not implemented: GET /swagger.yaml', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/swagger-complete.yaml')
  @ApiOperation({ summary: '완전한 OpenAPI 스펙 (YAML)' })
  async get_swagger_complete_yaml() {
    throw new HttpException('Not implemented: GET /swagger-complete.yaml', HttpStatus.NOT_IMPLEMENTED);
  }

  @Get('/openapi.json')
  @ApiOperation({ summary: 'OpenAPI 스펙 (JSON)' })
  async get_openapi_json() {
    throw new HttpException('Not implemented: GET /openapi.json', HttpStatus.NOT_IMPLEMENTED);
  }

}