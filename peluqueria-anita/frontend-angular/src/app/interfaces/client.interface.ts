export interface Client {
  id: number;
  name: string;
  email: string;
  phone: string;
  address?: string;
  birth_date?: string;
  preferences?: string;
  created_at: string;
  updated_at: string;
}

export interface CreateClientRequest {
  name: string;
  email: string;
  phone: string;
  address?: string;
  birth_date?: string;
  preferences?: string;
}

export interface UpdateClientRequest extends Partial<CreateClientRequest> {
  id: number;
}