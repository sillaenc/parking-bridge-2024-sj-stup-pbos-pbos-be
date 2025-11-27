import { Controller, Get } from '@nestjs/common';

@Controller('isalive')
export class IsaliveController {
  // GET /isalive/isalive -> plain "1"
  @Get('isalive')
  getIsAlive() {
    return '1';
  }

  // GET /isalive -> plain "1"
  @Get()
  rootIsAlive() {
    return '1';
  }
}
