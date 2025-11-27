import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
  });

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

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

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
