import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = environment.apiUrl;

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  private getAuthHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token ? `Bearer ${token}` : ''
    });
  }

  private handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'Ocurrió un error desconocido';
    
    if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = `Error: ${error.error.message}`;
    } else {
      // Server-side error
      if (error.status === 401) {
        this.authService.logout().subscribe();
        errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
      } else if (error.status === 403) {
        errorMessage = 'No tienes permisos para realizar esta acción.';
      } else if (error.status === 422) {
        errorMessage = 'Datos de entrada inválidos.';
      } else if (error.status === 500) {
        errorMessage = 'Error interno del servidor.';
      } else {
        errorMessage = error.error?.message || `Error ${error.status}: ${error.statusText}`;
      }
    }
    
    return throwError(() => new Error(errorMessage));
  }

  // Generic CRUD operations
  get<T>(endpoint: string): Observable<T> {
    return this.http.get<T>(`${this.apiUrl}${endpoint}`, {
      headers: this.getAuthHeaders()
    }).pipe(catchError(this.handleError.bind(this)));
  }

  post<T>(endpoint: string, data: any): Observable<T> {
    return this.http.post<T>(`${this.apiUrl}${endpoint}`, data, {
      headers: this.getAuthHeaders()
    }).pipe(catchError(this.handleError.bind(this)));
  }

  put<T>(endpoint: string, data: any): Observable<T> {
    return this.http.put<T>(`${this.apiUrl}${endpoint}`, data, {
      headers: this.getAuthHeaders()
    }).pipe(catchError(this.handleError.bind(this)));
  }

  delete<T>(endpoint: string): Observable<T> {
    return this.http.delete<T>(`${this.apiUrl}${endpoint}`, {
      headers: this.getAuthHeaders()
    }).pipe(catchError(this.handleError.bind(this)));
  }

  // Specific API endpoints
  getClients(params?: { page?: number; per_page?: number; search?: string }): Observable<any> {
    let queryParams = '';
    if (params) {
      const searchParams = new URLSearchParams();
      if (params.page) searchParams.append('page', params.page.toString());
      if (params.per_page) searchParams.append('per_page', params.per_page.toString());
      if (params.search) searchParams.append('search', params.search);
      queryParams = searchParams.toString() ? `?${searchParams.toString()}` : '';
    }
    return this.get(`/clients${queryParams}`);
  }

  getClient(id: number): Observable<any> {
    return this.get(`/clients/${id}`);
  }

  createClient(clientData: any): Observable<any> {
    return this.post('/clients', clientData);
  }

  updateClient(data: any): Observable<any> {
    return this.put(`/clients/${data.id}`, data);
  }

  deleteClient(id: number): Observable<any> {
    return this.delete(`/clients/${id}`);
  }

  getServices(): Observable<any> {
    return this.get('/services');
  }

  getService(id: number): Observable<any> {
    return this.get(`/services/${id}`);
  }

  createService(serviceData: any): Observable<any> {
    return this.post('/services', serviceData);
  }

  updateService(id: number, serviceData: any): Observable<any> {
    return this.put(`/services/${id}`, serviceData);
  }

  deleteService(id: number): Observable<any> {
    return this.delete(`/services/${id}`);
  }

  getAppointments(): Observable<any> {
    return this.get('/appointments');
  }

  getAppointment(id: number): Observable<any> {
    return this.get(`/appointments/${id}`);
  }

  createAppointment(appointmentData: any): Observable<any> {
    return this.post('/appointments', appointmentData);
  }

  updateAppointment(id: number, appointmentData: any): Observable<any> {
    return this.put(`/appointments/${id}`, appointmentData);
  }

  deleteAppointment(id: number): Observable<any> {
    return this.delete(`/appointments/${id}`);
  }

  getTodayAppointments(): Observable<any> {
    return this.get('/appointments/today');
  }

  getDashboardStats(): Observable<any> {
    return this.get('/dashboard/stats');
  }

  getPayments(): Observable<any> {
    return this.get('/payments');
  }

  createPayment(paymentData: any): Observable<any> {
    return this.post('/payments', paymentData);
  }
}
