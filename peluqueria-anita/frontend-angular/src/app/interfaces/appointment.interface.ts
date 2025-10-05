export interface Appointment {
  id: number;
  client_id: number;
  stylist_id: number;
  appointment_date: string;
  appointment_time: string;
  status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  notes?: string;
  total_amount: number;
  created_at: string;
  updated_at: string;
  
  // Relaciones
  client?: {
    id: number;
    name: string;
    email: string;
    phone: string;
  };
  stylist?: {
    id: number;
    name: string;
    email: string;
  };
  appointment_details?: AppointmentDetail[];
}

export interface AppointmentDetail {
  id: number;
  appointment_id: number;
  service_id: number;
  price: number;
  created_at: string;
  updated_at: string;
  
  // Relación
  service?: {
    id: number;
    name: string;
    description: string;
    duration: number;
  };
}

export interface CreateAppointmentRequest {
  client_id: number;
  stylist_id: number;
  appointment_date: string;
  appointment_time: string;
  notes?: string;
  services: {
    service_id: number;
    price: number;
  }[];
}

export interface UpdateAppointmentRequest extends Partial<CreateAppointmentRequest> {
  id: number;
  status?: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
}