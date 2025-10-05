export interface Service {
  id: number;
  name: string;
  description: string;
  price: number;
  duration: number; // en minutos
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface CreateServiceRequest {
  name: string;
  description: string;
  price: number;
  duration: number;
  is_active?: boolean;
}

export interface UpdateServiceRequest extends Partial<CreateServiceRequest> {
  id: number;
}