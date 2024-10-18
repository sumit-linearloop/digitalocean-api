import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return (
      'Hello World! + ' +
      'NODE_ENV ' +
      process.env.NODE_ENV +
      ' + ' +
      'PORT ' +
      process.env.PORT
    );
  }
}