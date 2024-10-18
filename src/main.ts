import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';

// Load environment variables from .env file
dotenv.config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const PORT = process.env.PORT || 1500;  // Default to 3000 if not specified
  const ENV = process.env.NODE_ENV || 'development';  // Default to development if not specified

  await app.listen(PORT, () => {
    console.log(`Server is running on http://0.0.0.0:${PORT}`);
    console.log(`Environment: ${ENV}`);
  });
}
bootstrap();
