import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { IdToUidInterceptor } from './common/interceptors/id-to-uid.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
  });
  const requestLogger = new Logger('HTTP');

  // CORS/헤더를 레거시 형태(*)에 맞춤
  app.enableCors({
    origin: '*',
    credentials: false,
    allowedHeaders: ['Origin', 'Content-Type', 'X-Auth-Token', 'Authorization'],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  });
  const http = app.getHttpAdapter().getInstance();
  http.disable('x-powered-by'); // Express 표시 제거
  http.set('etag', false); // ETag 제거
  http.use((_: any, res: any, next: any) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, Content-Type, X-Auth-Token, Authorization');
    next();
  });
  http.use((req: any, res: any, next: any) => {
    const stringifySafe = (payload: unknown) => {
      try {
        return JSON.stringify(payload);
      } catch {
        return '[unserializable]';
      }
    };
    const { method, originalUrl } = req;
    const contentType: string = req?.headers?.['content-type'] ?? '';
    const queryStr = req?.query && Object.keys(req.query).length > 0 ? stringifySafe(req.query) : '';
    const bodyStr =
      contentType.includes('multipart/form-data') || contentType.includes('octet-stream')
        ? '[binary/body omitted]'
        : req?.body && Object.keys(req.body).length > 0
        ? stringifySafe(req.body)?.slice(0, 500)
        : '';

    const parts = [`REQ ${method} ${originalUrl}`];
    if (queryStr) parts.push(`query=${queryStr}`);
    if (bodyStr) parts.push(`body=${bodyStr}`);
    requestLogger.log(parts.join(' | '));

    res.on('finish', () => {
      requestLogger.log(`RES ${method} ${originalUrl} -> ${res.statusCode}`);
    });
    next();
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.useGlobalInterceptors(new IdToUidInterceptor());

  const config = new DocumentBuilder()
    .setTitle('PBOS Backend')
    .setDescription('PBOS NestJS migration API')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  // pbos_be_v2에서 사용하던 경로를 맞추기 위해 /docs-complete로 서빙 (docs는 별칭)
  SwaggerModule.setup('docs-complete', app, document);
  SwaggerModule.setup('docs', app, document);

  const port = process.env.PORT ? Number(process.env.PORT) : 3000;
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`PBOS NestJS server listening on port ${port}`);
}

bootstrap();
