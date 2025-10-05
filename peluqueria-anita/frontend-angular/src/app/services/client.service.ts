import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Client {
  id?: number;
  name: string;
  email?: string;
  phone: string;
  address?: string;
  birth_date?: string;
  gender?: 'male' | 'female' | 'other';
  notes?: string;
  is_active?: boolean;
  appointments_count?: number;
  total_spent?: number;
  last_appointment?: string;
  created_at?: string;
  updated_at?: string;
}

export interface ClientFilters {
  search?: string;
  is_active?: boolean;
  gender?: string;
  sort_by?: string;
  sort_order?: 'asc' | 'desc';
  per_page?: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  current_page: number;
  last_page: number;
  per_page: number;
  total: number;
}

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  private apiUrl = `${environment.apiUrl}/clients`;

  constructor(private http: HttpClient) {}

  /**
   * Obtener lista de clientes con filtros
   */
  getClients(filters: ClientFilters = {}): Observable<ApiResponse<PaginatedResponse<Client>>> {
    let params = new HttpParams();
    
    Object.keys(filters).forEach(key => {
      const value = (filters as any)[key];
      if (value !== null && value !== undefined && value !== '') {
        params = params.set(key, value.toString());
      }
    });

    return this.http.get<ApiResponse<PaginatedResponse<Client>>>(this.apiUrl, { params });
  }

  /**
   * Obtener cliente por ID
   */
  getClient(id: number): Observable<ApiResponse<Client>> {
    return this.http.get<ApiResponse<Client>>(`${this.apiUrl}/${id}`);
  }

  /**
   * Crear nuevo cliente
   */
  createClient(client: Partial<Client>): Observable<ApiResponse<Client>> {
    console.log('ClientService.createClient called with:', client);
    console.log('API URL:', this.apiUrl);
    return this.http.post<ApiResponse<Client>>(this.apiUrl, client);
  }

  /**
   * Actualizar cliente
   */
  updateClient(id: number, client: Partial<Client>): Observable<ApiResponse<Client>> {
    return this.http.put<ApiResponse<Client>>(`${this.apiUrl}/${id}`, client);
  }

  /**
   * Eliminar cliente
   */
  deleteClient(id: number): Observable<ApiResponse<any>> {
    return this.http.delete<ApiResponse<any>>(`${this.apiUrl}/${id}`);
  }

  /**
   * Activar/desactivar cliente
   */
  toggleClientStatus(id: number): Observable<ApiResponse<Client>> {
    return this.http.patch<ApiResponse<Client>>(`${this.apiUrl}/${id}/toggle-status`, {});
  }

  /**
   * Obtener historial de citas del cliente
   */
  getClientAppointments(id: number): Observable<ApiResponse<PaginatedResponse<any>>> {
    return this.http.get<ApiResponse<PaginatedResponse<any>>>(`${this.apiUrl}/${id}/appointments`);
  }

  /**
   * Obtener estadísticas de clientes
   */
  getClientStats(): Observable<ApiResponse<any>> {
    return this.http.get<ApiResponse<any>>(`${this.apiUrl}/stats`);
  }
}