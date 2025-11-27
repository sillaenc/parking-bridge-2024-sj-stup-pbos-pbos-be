import { Injectable } from '@nestjs/common';

@Injectable()
export class LedService {
  async calculate() {
    // TODO: 실제 LED 계산 로직으로 대체
    return {
      led: 'calc',
      status: 'ok',
      colors: [],
    };
  }
}
