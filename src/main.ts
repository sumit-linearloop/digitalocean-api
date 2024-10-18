import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const PORT = process.env.PORT || 3000;
  const ENV = process.env.NODE_ENV || 'development';
  await app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT} +  le laie lee`);
    console.log(`Environment: ${ENV}`);
  });
}
bootstrap();
