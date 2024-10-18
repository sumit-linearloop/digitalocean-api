import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,         // Makes the ConfigModule available globally
      envFilePath: '.env',   // Specifies the path to your .env file
    }),
  ],
  controllers: [AppController],  // Registers your application controllers
  providers: [AppService],        // Registers your application services
})
export class AppModule {}
