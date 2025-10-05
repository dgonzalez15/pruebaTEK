import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap } from 'rxjs';
import { environment } from '../../environments/environment';

export interface User {
  id: number;
  name: string;
  email: string;
  role: string;
  created_at: string;
  updated_at: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data: {
    user: User;
    access_token: string;
    token_type: string;
  };
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
  password_confirmation: string;
  role?: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = environment.apiUrl;
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(private http: HttpClient) {
    // Verificar si hay un token guardado al inicializar el servicio
    this.checkStoredToken();
  }

  private checkStoredToken(): void {
    // Verificar si estamos en el browser antes de usar localStorage
    if (typeof window === 'undefined' || typeof localStorage === 'undefined') {
      return;
    }
    
    const token = localStorage.getItem('token');
    const user = localStorage.getItem('user');
    
    if (token && user) {
      try {
        const parsedUser = JSON.parse(user);
        this.currentUserSubject.next(parsedUser);
      } catch (error) {
        // Si hay error al parsear, limpiar el storage
        this.logout();
      }
    }
  }

  login(email: string, password: string, rememberMe: boolean = false): Observable<AuthResponse> {
    const loginData: LoginRequest = { email, password };
    
    return this.http.post<AuthResponse>(`${this.apiUrl}/auth/login`, loginData)
      .pipe(
        tap(response => {
          // Verificar si estamos en el browser
          if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
            // Guardar token y usuario
            localStorage.setItem('token', response.data.access_token);
            localStorage.setItem('user', JSON.stringify(response.data.user));
          }
          
          // Actualizar el BehaviorSubject
          this.currentUserSubject.next(response.data.user);
        })
      );
  }

  register(userData: RegisterRequest): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/auth/register`, userData)
      .pipe(
        tap(response => {
          // Verificar si estamos en el browser
          if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
            // Guardar token y usuario después del registro
            localStorage.setItem('token', response.data.access_token);
            localStorage.setItem('user', JSON.stringify(response.data.user));
          }
          
          // Actualizar el BehaviorSubject
          this.currentUserSubject.next(response.data.user);
        })
      );
  }

  logout(): Observable<any> {
    const token = this.getToken();
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    
    return this.http.post(`${this.apiUrl}/auth/logout`, {}, { headers })
      .pipe(
        tap(() => {
          // Verificar si estamos en el browser
          if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
            // Limpiar storage local
            localStorage.removeItem('token');
            localStorage.removeItem('user');
          }
          
          // Actualizar el BehaviorSubject
          this.currentUserSubject.next(null);
        })
      );
  }

  getCurrentUser(): User | null {
    return this.currentUserSubject.value;
  }

  isAuthenticated(): boolean {
    if (typeof window === 'undefined' || typeof localStorage === 'undefined') {
      return false;
    }
    return !!localStorage.getItem('token') && !!this.currentUserSubject.value;
  }

  getToken(): string | null {
    if (typeof window === 'undefined' || typeof localStorage === 'undefined') {
      return null;
    }
    return localStorage.getItem('token');
  }

  // Métodos para verificar roles
  hasRole(role: string): boolean {
    const user = this.getCurrentUser();
    return user ? user.role === role : false;
  }

  isAdmin(): boolean {
    return this.hasRole('admin');
  }

  isStylist(): boolean {
    return this.hasRole('stylist');
  }

  isClient(): boolean {
    return this.hasRole('client');
  }

  /**
   * Verificar si el usuario tiene un permiso específico
   * Por ahora es una implementación básica basada en roles
   */
  hasPermission(permission: string): boolean {
    const currentUser = this.currentUserSubject.value;
    
    // Para operaciones de lectura, permitir siempre (temporal para debugging)
    const readOnlyPermissions = ['view_appointments', 'view_clients', 'view_services'];
    if (readOnlyPermissions.some(p => permission.includes('view_') || permission.includes('create_'))) {
      return true;
    }
    
    if (!currentUser) return false;

    // Los administradores tienen todos los permisos
    if (this.isAdmin()) return true;

    // Los estilistas tienen permisos limitados
    if (this.isStylist()) {
      const stylistPermissions = [
        'view_appointments',
        'create_appointments', 
        'update_appointments',
        'view_clients',
        'create_clients',
        'update_clients',
        'view_attentions',
        'create_attentions',
        'update_attentions',
        'delete_attentions'
      ];
      return stylistPermissions.includes(permission);
    }

    // Los clientes solo pueden ver sus propias citas
    if (this.isClient()) {
      const clientPermissions = [
        'view_own_appointments',
        'create_appointments'
      ];
      return clientPermissions.includes(permission);
    }

    return false;
  }

  getAuthHeaders(): HttpHeaders {
    const token = this.getToken();
    return new HttpHeaders().set('Authorization', `Bearer ${token || ''}`);
  }

  /**
   * Método temporal para establecer un token de prueba
   * SOLO PARA DESARROLLO - REMOVER EN PRODUCCIÓN
   */
  setTestToken(): void {
    // Este es un token de prueba - en un caso real vendrían del login
    const testToken = 'test-token-123';
    const testUser = {
      id: 1,
      name: 'Usuario de Prueba',
      email: 'test@peluqueria.com',
      role: 'admin',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      localStorage.setItem('token', testToken);
      localStorage.setItem('user', JSON.stringify(testUser));
    }
    
    this.currentUserSubject.next(testUser);
    console.log('Test token and user set');
  }
}
