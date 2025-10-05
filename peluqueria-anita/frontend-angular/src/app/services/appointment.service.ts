import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Appointment {
  id?: number;
  client_id: number;
  user_id: number;
  appointment_date: string;
  start_time: string;
  end_time: string;
  status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled' | 'no_show';
  total_amount: number;
  notes?: string;
  client?: any;
  stylist?: any;
  user?: any;
  appointmentDetails?: any[];
  services?: any[];
  created_at?: string;
  updated_at?: string;
}

export interface AppointmentFilters {
  date?: string;
  date_from?: string;
  date_to?: string;
  user_id?: number;
  client_id?: number;
  status?: string;
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
export class AppointmentService {
  private apiUrl = `${environment.apiUrl}/appointments`;

  constructor(private http: HttpClient) {}

  /**
   * Obtener lista de citas con filtros
   */
  getAppointments(filters: AppointmentFilters = {}): Observable<ApiResponse<PaginatedResponse<Appointment>>> {
    let params = new HttpParams();
    
    Object.keys(filters).forEach(key => {
      const value = (filters as any)[key];
      if (value !== null && value !== undefined && value !== '') {
        params = params.set(key, value.toString());
      }
    });

    return this.http.get<ApiResponse<PaginatedResponse<Appointment>>>(this.apiUrl, { params });
  }

  /**
   * Obtener cita por ID
   */
  getAppointment(id: number): Observable<ApiResponse<Appointment>> {
    return this.http.get<ApiResponse<Appointment>>(`${this.apiUrl}/${id}`);
  }

  /**
   * Crear nueva cita
   */
  createAppointment(appointment: Partial<Appointment>): Observable<ApiResponse<Appointment>> {
    return this.http.post<ApiResponse<Appointment>>(this.apiUrl, appointment);
  }

  /**
   * Actualizar cita
   */
  updateAppointment(id: number, appointment: Partial<Appointment>): Observable<ApiResponse<Appointment>> {
    return this.http.put<ApiResponse<Appointment>>(`${this.apiUrl}/${id}`, appointment);
  }

  /**
   * Eliminar cita
   */
  deleteAppointment(id: number): Observable<ApiResponse<any>> {
    return this.http.delete<ApiResponse<any>>(`${this.apiUrl}/${id}`);
  }

  /**
   * Obtener citas del día
   */
  getTodayAppointments(userId?: number, date?: string): Observable<ApiResponse<Appointment[]>> {
    let params = new HttpParams();
    if (userId) params = params.set('user_id', userId.toString());
    if (date) params = params.set('date', date);

    return this.http.get<ApiResponse<Appointment[]>>(`${this.apiUrl}/today`, { params });
  }

  /**
   * Obtener horarios disponibles
   */
  getAvailableSlots(stylistId: number, date: string): Observable<ApiResponse<any>> {
    const params = new HttpParams()
      .set('user_id', stylistId.toString()) // Cambiar a user_id según la API
      .set('date', date);

    return this.http.get<ApiResponse<any>>(`${this.apiUrl}/available-slots`, { params });
  }

  /**
   * Buscar citas por cliente
   */
  searchAppointmentsByClient(search: string): Observable<ApiResponse<PaginatedResponse<Appointment>>> {
    const params = new HttpParams().set('search', search);
    return this.http.get<ApiResponse<PaginatedResponse<Appointment>>>(`${this.apiUrl}/search`, { params });
  }

  /**
   * Confirmar cita
   */
  confirmAppointment(id: number): Observable<ApiResponse<Appointment>> {
    return this.http.patch<ApiResponse<Appointment>>(`${this.apiUrl}/${id}/confirm`, {});
  }

  /**
   * Marcar cita como completada
   */
  completeAppointment(id: number): Observable<ApiResponse<Appointment>> {
    return this.http.patch<ApiResponse<Appointment>>(`${this.apiUrl}/${id}/complete`, {});
  }

  /**
   * Cancelar cita
   */
  cancelAppointment(id: number, notes?: string): Observable<ApiResponse<Appointment>> {
    return this.http.patch<ApiResponse<Appointment>>(`${this.apiUrl}/${id}/cancel`, { notes });
  }

  /**
   * Reprogramar cita
   */
  rescheduleAppointment(id: number, data: any): Observable<ApiResponse<Appointment>> {
    return this.http.patch<ApiResponse<Appointment>>(`${this.apiUrl}/${id}/reschedule`, data);
  }

  /**
   * Cambiar estado de cita
   */
  updateAppointmentStatus(id: number, status: string, notes?: string): Observable<ApiResponse<Appointment>> {
    return this.http.patch<ApiResponse<Appointment>>(`${this.apiUrl}/${id}/status`, { status, notes });
  }

  /**
   * Obtener estadísticas de citas
   */
  getAppointmentStats(filters: any = {}): Observable<ApiResponse<any>> {
    let params = new HttpParams();
    
    Object.keys(filters).forEach(key => {
      const value = filters[key];
      if (value !== null && value !== undefined && value !== '') {
        params = params.set(key, value.toString());
      }
    });

    return this.http.get<ApiResponse<any>>(`${this.apiUrl}/stats`, { params });
  }
}