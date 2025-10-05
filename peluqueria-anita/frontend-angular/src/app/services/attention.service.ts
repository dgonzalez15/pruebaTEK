import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Attention {
  id?: number;
  appointment_id: number;
  client_id: number;
  user_id: number;
  service_id: number;
  attention_date: string;
  start_time: string;
  end_time: string;
  status: 'started' | 'in_progress' | 'completed' | 'cancelled';
  service_price: number;
  observations?: string;
  products_used?: string;
  tip_amount?: number;
  client_satisfaction?: 'very_unsatisfied' | 'unsatisfied' | 'neutral' | 'satisfied' | 'very_satisfied';
  notes?: string;
  client?: any;
  user?: any;
  service?: any;
  appointment?: any;
  created_at?: string;
  updated_at?: string;
}

export interface AttentionFilters {
  date?: string;
  status?: string;
  stylist_id?: number;
  client_id?: number;
  search?: string;
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
export class AttentionService {
  private apiUrl = `${environment.apiUrl}/attentions`;

  constructor(private http: HttpClient) {}

  /**
   * Obtener lista de atenciones con filtros
   */
  getAttentions(filters: AttentionFilters = {}): Observable<ApiResponse<PaginatedResponse<Attention>>> {
    let params = new HttpParams();
    
    Object.keys(filters).forEach(key => {
      const value = (filters as any)[key];
      if (value !== null && value !== undefined && value !== '') {
        params = params.set(key, value.toString());
      }
    });

    return this.http.get<ApiResponse<PaginatedResponse<Attention>>>(this.apiUrl, { params });
  }

  /**
   * Obtener atención por ID
   */
  getAttention(id: number): Observable<ApiResponse<Attention>> {
    return this.http.get<ApiResponse<Attention>>(`${this.apiUrl}/${id}`);
  }

  /**
   * Crear nueva atención
   */
  createAttention(attention: Partial<Attention>): Observable<ApiResponse<Attention>> {
    return this.http.post<ApiResponse<Attention>>(this.apiUrl, attention);
  }

  /**
   * Actualizar atención
   */
  updateAttention(id: number, attention: Partial<Attention>): Observable<ApiResponse<Attention>> {
    return this.http.put<ApiResponse<Attention>>(`${this.apiUrl}/${id}`, attention);
  }

  /**
   * Eliminar atención
   */
  deleteAttention(id: number): Observable<ApiResponse<any>> {
    return this.http.delete<ApiResponse<any>>(`${this.apiUrl}/${id}`);
  }

  /**
   * Cambiar estado de atención
   */
  updateAttentionStatus(id: number, status: string, notes?: string): Observable<ApiResponse<Attention>> {
    return this.http.patch<ApiResponse<Attention>>(`${this.apiUrl}/${id}/status`, { status, notes });
  }

  /**
   * Obtener estadísticas de atenciones
   */
  getAttentionStats(dateFrom?: string, dateTo?: string): Observable<ApiResponse<any>> {
    let params = new HttpParams();
    if (dateFrom) params = params.set('date_from', dateFrom);
    if (dateTo) params = params.set('date_to', dateTo);

    return this.http.get<ApiResponse<any>>(`${this.apiUrl}/stats`, { params });
  }
}