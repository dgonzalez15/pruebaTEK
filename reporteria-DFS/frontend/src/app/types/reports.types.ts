/**
 * ====================================================================
 * TIPOS E INTERFACES DE REPORTES - PELUQUERÍA ANITA
 * ====================================================================
 * 
 * Definiciones TypeScript para todos los reportes del sistema
 * Compatible con Angular 18+
 * 
 * @author Diego González
 * @version 1.0.0
 */

/**
 * Interfaz base para respuestas de API
 */
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  error?: string;
  trace?: string;
}

/**
 * Interfaz para respuestas paginadas
 */
export interface PaginatedResponse<T> {
  data: T[];
  pagination: Pagination;
  summary?: any;
}

export interface Pagination {
  current_page: number;
  last_page: number;
  per_page: number;
  total: number;
}

/**
 * ====================================================================
 * REPORTE A: CLIENTES POR CITA
 * ====================================================================
 */

export interface ClientByAppointmentReport {
  appointment_id: number;
  appointment_date: string;
  appointment_time: string;
  status: AppointmentStatus;
  status_label: string;
  client: ClientBasicInfo;
  stylist: StylistInfo;
  total_amount: string;
  notes: string | null;
}

export interface ClientByAppointmentSummary {
  total_appointments: number;
  total_amount: string;
  filters_applied: {
    date_range: boolean;
    status: string;
    specific_client: boolean;
  };
}

/**
 * ====================================================================
 * REPORTE B: CLIENTES, ATENCIONES Y SERVICIOS
 * ====================================================================
 */

export interface ClientAttentionServicesReport {
  client: ClientFullInfo;
  attentions: AttentionDetail[];
  summary: ClientAttentionSummary;
}

export interface AttentionDetail {
  attention_id: number;
  attention_date: string;
  appointment_id: number;
  services_count: number;
  services: ServiceDetail[];
  attention_total: string;
}

export interface ServiceDetail {
  service_id: number;
  service_name: string;
  service_price: string;
  duration_minutes: number;
}

export interface ClientAttentionSummary {
  total_attentions: number;
  total_services: number;
  total_amount: string;
}

export interface GeneralSummary {
  total_clients: number;
  total_attentions: number;
  total_services: number;
  total_revenue: string;
}

/**
 * ====================================================================
 * REPORTE C: VENTAS POR CLIENTE
 * ====================================================================
 */

export interface ClientSalesReport {
  client: ClientBasicInfo;
  appointments: AppointmentSale[];
  summary: ClientSalesSummary;
}

export interface AppointmentSale {
  appointment_id: number;
  date: string;
  time: string;
  status: AppointmentStatus;
  status_label: string;
  services_count: number;
  services: ServiceSale[];
  total_amount: string;
}

export interface ServiceSale {
  service_name: string;
  price: string;
}

export interface ClientSalesSummary {
  total_appointments: number;
  total_services: number;
  total_spent: string;
}

/**
 * ====================================================================
 * REPORTE D: CITAS Y ATENCIONES
 * ====================================================================
 */

export interface AppointmentAttentionReport {
  appointment_id: number;
  date: string;
  time: string;
  status: AppointmentStatus;
  status_label: string;
  client: ClientBasicInfo;
  stylist: StylistInfo;
  has_attention: boolean;
  attention: AttentionInfo | null;
  total_amount: string;
}

export interface AttentionInfo {
  attention_id: number;
  attention_date: string;
  services_count: number;
  services: ServiceSale[];
}

export interface AppointmentAttentionSummary {
  total_appointments: number;
  attended: number;
  pending: number;
  attendance_rate: number;
}

/**
 * ====================================================================
 * REPORTE CONSOLIDADO - DASHBOARD
 * ====================================================================
 */

export interface ConsolidatedReport {
  period: ReportPeriod;
  metrics: ConsolidatedMetrics;
  rankings: ConsolidatedRankings;
  trends: ConsolidatedTrends;
}

export interface ReportPeriod {
  start_date: string;
  end_date: string;
  days: number;
}

export interface ConsolidatedMetrics {
  clients: ClientMetrics;
  appointments: AppointmentMetrics;
  attentions: AttentionMetrics;
  revenue: RevenueMetrics;
}

export interface ClientMetrics {
  total: number;
  active: number;
  inactive: number;
  new_in_period: number;
}

export interface AppointmentMetrics {
  total: number;
  completed: number;
  cancelled: number;
  completion_rate: number;
  cancellation_rate: number;
  by_status: { [key: string]: number };
}

export interface AttentionMetrics {
  total: number;
  average_per_day: number;
}

export interface RevenueMetrics {
  total: string;
  average_per_appointment: string;
  average_per_day: string;
}

export interface ConsolidatedRankings {
  top_services: TopService[];
  top_clients: TopClient[];
}

export interface TopService {
  id: number;
  name: string;
  count: number;
  revenue: string;
}

export interface TopClient {
  id: number;
  full_name: string;
  email: string;
  phone: string;
  appointments_count: number;
  total_spent: string;
}

export interface ConsolidatedTrends {
  monthly_sales: MonthlySale[];
}

export interface MonthlySale {
  month: string;
  total: string;
}

/**
 * ====================================================================
 * TIPOS COMUNES
 * ====================================================================
 */

export interface ClientBasicInfo {
  id: number;
  full_name: string;
  email: string;
  phone: string;
}

export interface ClientFullInfo extends ClientBasicInfo {
  address: string | null;
}

export interface StylistInfo {
  id: number | null;
  name: string;
}

export type AppointmentStatus = 
  | 'scheduled' 
  | 'confirmed' 
  | 'completed' 
  | 'cancelled' 
  | 'no_show';

/**
 * ====================================================================
 * FILTROS PARA REPORTES
 * ====================================================================
 */

export interface ReportFilters {
  start_date?: string;
  end_date?: string;
  status?: AppointmentStatus;
  client_id?: number;
  per_page?: number;
}

export interface ExportReportRequest {
  report_type: ReportType;
  start_date?: string;
  end_date?: string;
  status?: AppointmentStatus;
  client_id?: number;
}

export type ReportType = 
  | 'clients_by_appointment'
  | 'clients_attentions_services'
  | 'client_sales'
  | 'appointments_attentions'
  | 'consolidated';

/**
 * ====================================================================
 * CONSTANTES
 * ====================================================================
 */

export const APPOINTMENT_STATUS_LABELS: Record<AppointmentStatus, string> = {
  scheduled: 'Agendada',
  confirmed: 'Confirmada',
  completed: 'Completada',
  cancelled: 'Cancelada',
  no_show: 'No asistió'
};

export const APPOINTMENT_STATUS_COLORS: Record<AppointmentStatus, string> = {
  scheduled: 'warning',
  confirmed: 'info',
  completed: 'success',
  cancelled: 'danger',
  no_show: 'secondary'
};

export const REPORT_NAMES: Record<ReportType, string> = {
  clients_by_appointment: 'Reporte A: Clientes por Cita',
  clients_attentions_services: 'Reporte B: Clientes, Atenciones y Servicios',
  client_sales: 'Reporte C: Ventas por Cliente',
  appointments_attentions: 'Reporte D: Citas y Atenciones',
  consolidated: 'Reporte Consolidado - Dashboard'
};
