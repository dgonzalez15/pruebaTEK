import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import {
  ApiResponse,
  PaginatedResponse,
  ClientByAppointmentReport,
  ClientByAppointmentSummary,
  ClientAttentionServicesReport,
  GeneralSummary,
  ClientSalesReport,
  AppointmentAttentionReport,
  AppointmentAttentionSummary,
  ConsolidatedReport,
  ReportFilters,
  ExportReportRequest,
  ReportType
} from '../types/reports.types';

/**
 * ====================================================================
 * SERVICIO DE REPORTES - PELUQUERÍA ANITA
 * ====================================================================
 * 
 * Servicio Angular para consumir la API de reportes
 * Compatible con Angular 18+
 * 
 * Uso:
 * 1. Importa este servicio en tu componente
 * 2. Inyéctalo en el constructor
 * 3. Llama a los métodos para obtener los reportes
 * 
 * Ejemplo:
 * ```typescript
 * constructor(private reportService: ReportService) {}
 * 
 * ngOnInit() {
 *   this.reportService.getClientsByAppointment({ start_date: '2024-01-01' })
 *     .subscribe(data => console.log(data));
 * }
 * ```
 * 
 * @author Diego González
 * @version 1.0.0
 */
@Injectable({
  providedIn: 'root'
})
export class ReportService {
  private apiUrl = `${environment.apiUrl}/reports`;

  constructor(private http: HttpClient) {}

  /**
   * REPORTE A: Clientes por Cita
   * 
   * Obtiene un listado paginado de todas las citas con información
   * detallada de los clientes.
   * 
   * @param filters Filtros opcionales para el reporte
   * @returns Observable con la respuesta paginada
   */
  getClientsByAppointment(filters?: ReportFilters): Observable<{
    data: PaginatedResponse<ClientByAppointmentReport>;
    summary: ClientByAppointmentSummary;
  }> {
    const params = this.buildParams(filters);
    
    return this.http.get<ApiResponse<any>>(`${this.apiUrl}/clients-by-appointment`, { params })
      .pipe(
        map(response => ({
          data: response.data,
          summary: response.data.summary || {}
        }))
      );
  }

  /**
   * REPORTE B: Clientes, Atenciones y Servicios
   * 
   * Obtiene una vista completa de clientes con todas sus atenciones
   * y servicios realizados.
   * 
   * @param filters Filtros opcionales para el reporte
   * @returns Observable con la lista de clientes y resumen general
   */
  getClientsAttentionsAndServices(filters?: ReportFilters): Observable<{
    data: ClientAttentionServicesReport[];
    general_summary: GeneralSummary;
  }> {
    const params = this.buildParams(filters);
    
    return this.http.get<ApiResponse<any>>(`${this.apiUrl}/clients-attentions-services`, { params })
      .pipe(
        map(response => ({
          data: response.data.data || response.data,
          general_summary: response.data.general_summary || {}
        }))
      );
  }

  /**
   * REPORTE C: Ventas por Cliente
   * 
   * Obtiene información detallada de ventas por cliente incluyendo
   * todas sus citas y servicios realizados.
   * 
   * @param filters Filtros opcionales para el reporte
   * @returns Observable con la lista de clientes y resumen general
   */
  getClientSales(filters?: ReportFilters): Observable<{
    data: ClientSalesReport[];
    general_summary: GeneralSummary;
  }> {
    const params = this.buildParams(filters);
    
    return this.http.get<ApiResponse<any>>(`${this.apiUrl}/client-sales`, { params })
      .pipe(
        map(response => ({
          data: response.data.data || response.data,
          general_summary: response.data.general_summary || {}
        }))
      );
  }

  /**
   * REPORTE D: Citas y Atenciones
   * 
   * Obtiene un listado de todas las citas con información sobre
   * si tienen atención registrada o no.
   * 
   * @param filters Filtros opcionales para el reporte
   * @returns Observable con la respuesta paginada y resumen
   */
  getAppointmentsAndAttentions(filters?: ReportFilters): Observable<{
    data: PaginatedResponse<AppointmentAttentionReport>;
    summary: AppointmentAttentionSummary;
  }> {
    const params = this.buildParams(filters);
    
    return this.http.get<ApiResponse<any>>(`${this.apiUrl}/appointments-attentions`, { params })
      .pipe(
        map(response => ({
          data: response.data,
          summary: response.data.summary || {}
        }))
      );
  }

  /**
   * REPORTE CONSOLIDADO - Dashboard Principal
   * 
   * Obtiene todas las métricas importantes del negocio incluyendo
   * clientes, citas, atenciones, ingresos y rankings.
   * 
   * @param filters Filtros opcionales (principalmente fechas)
   * @returns Observable con el reporte consolidado completo
   */
  getConsolidatedReport(filters?: Pick<ReportFilters, 'start_date' | 'end_date'>): Observable<ConsolidatedReport> {
    const params = this.buildParams(filters);
    
    return this.http.get<ApiResponse<ConsolidatedReport>>(`${this.apiUrl}/consolidated`, { params })
      .pipe(
        map(response => response.data)
      );
  }

  /**
   * EXPORTAR REPORTE
   * 
   * Descarga un reporte en formato CSV.
   * 
   * @param request Configuración del reporte a exportar
   * @returns Observable con el archivo CSV como Blob
   */
  exportReport(request: ExportReportRequest): Observable<Blob> {
    return this.http.post(`${this.apiUrl}/export`, request, {
      responseType: 'blob'
    });
  }

  /**
   * DESCARGAR REPORTE CSV
   * 
   * Método auxiliar para descargar el CSV directamente al navegador.
   * 
   * @param request Configuración del reporte a exportar
   * @param filename Nombre del archivo (opcional)
   */
  downloadReportCSV(request: ExportReportRequest, filename?: string): void {
    this.exportReport(request).subscribe({
      next: (blob) => {
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename || this.generateFilename(request.report_type);
        link.click();
        window.URL.revokeObjectURL(url);
      },
      error: (error) => {
        console.error('Error al exportar reporte:', error);
        alert('Hubo un error al exportar el reporte. Por favor, intenta nuevamente.');
      }
    });
  }

  /**
   * MÉTODOS AUXILIARES PRIVADOS
   */

  /**
   * Construye los parámetros HTTP para las peticiones
   */
  private buildParams(filters?: ReportFilters): HttpParams {
    let params = new HttpParams();

    if (filters) {
      if (filters.start_date) {
        params = params.set('start_date', filters.start_date);
      }
      if (filters.end_date) {
        params = params.set('end_date', filters.end_date);
      }
      if (filters.status) {
        params = params.set('status', filters.status);
      }
      if (filters.client_id) {
        params = params.set('client_id', filters.client_id.toString());
      }
      if (filters.per_page) {
        params = params.set('per_page', filters.per_page.toString());
      }
    }

    return params;
  }

  /**
   * Genera un nombre de archivo para la descarga CSV
   */
  private generateFilename(reportType: ReportType): string {
    const date = new Date().toISOString().split('T')[0];
    const time = new Date().toTimeString().split(' ')[0].replace(/:/g, '-');
    return `reporte_${reportType}_${date}_${time}.csv`;
  }

  /**
   * MÉTODOS AUXILIARES PARA FORMATEO
   */

  /**
   * Formatea un monto a moneda local
   */
  formatCurrency(amount: string | number): string {
    const num = typeof amount === 'string' ? parseFloat(amount) : amount;
    return new Intl.NumberFormat('es-CO', {
      style: 'currency',
      currency: 'COP',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(num);
  }

  /**
   * Formatea una fecha a formato local
   */
  formatDate(date: string | Date): string {
    const d = typeof date === 'string' ? new Date(date) : date;
    return new Intl.DateTimeFormat('es-CO', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    }).format(d);
  }

  /**
   * Formatea una fecha corta
   */
  formatShortDate(date: string | Date): string {
    const d = typeof date === 'string' ? new Date(date) : date;
    return new Intl.DateTimeFormat('es-CO', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).format(d);
  }

  /**
   * Formatea una hora
   */
  formatTime(time: string): string {
    return time.substring(0, 5); // Retorna HH:mm
  }

  /**
   * Calcula el porcentaje
   */
  calculatePercentage(value: number, total: number): number {
    if (total === 0) return 0;
    return Math.round((value / total) * 100 * 100) / 100; // Redondea a 2 decimales
  }
}
