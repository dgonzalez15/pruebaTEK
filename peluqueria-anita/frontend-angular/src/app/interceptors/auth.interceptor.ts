import { Injectable } from '@angular/core';
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {

  constructor(private authService: AuthService) { }

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    // Obtener el token del AuthService
    const token = this.authService.getToken();
    
    console.log('AuthInterceptor - Request URL:', request.url);
    console.log('AuthInterceptor - Token available:', !!token);
    
    // Si hay token, agregar el header Authorization
    if (token) {
      console.log('Adding Authorization header with token');
      const authRequest = request.clone({
        headers: request.headers.set('Authorization', `Bearer ${token}`)
      });
      return next.handle(authRequest);
    }
    
    console.log('No token available, sending request without authorization');
    // Si no hay token, enviar la request original
    return next.handle(request);
  }
}