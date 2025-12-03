import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable()
export class IdToUidInterceptor implements NestInterceptor {
  intercept(_context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(map((data) => this.transform(data)));
  }

  private transform(value: any): any {
    if (Array.isArray(value)) {
      return value.map((item) => this.transform(item));
    }

    if (!this.isPlainObject(value)) {
      return value;
    }

    const result: Record<string, any> = {};
    for (const [key, val] of Object.entries(value)) {
      if (key === 'id') {
        // 'id'를 'uid'로 치환
        result['uid'] = this.transform(val);
      } else {
        result[key] = this.transform(val);
      }
    }
    return result;
  }

  private isPlainObject(value: any) {
    if (value === null || typeof value !== 'object') return false;
    if (value instanceof Date) return false;
    if (value instanceof Buffer) return false;
    return Object.getPrototypeOf(value) === Object.prototype;
  }
}
