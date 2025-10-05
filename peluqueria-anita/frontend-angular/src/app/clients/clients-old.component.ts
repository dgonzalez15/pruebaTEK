import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators, FormsModule } from '@angular/forms';
import { ClientService, Client, ClientFilters } from '../services/client.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-clients',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule],
  templateUrl: './clients.component.html',
  styleUrl: './clients.component.scss'
})
export class ClientsComponent implements OnInit {
  clients: Client[] = [];
  loading = false;
  showModal = false;
  showDeleteModal = false;
  editingClient: Client | null = null;
  deletingClient: Client | null = null;
  clientForm: FormGroup;
  
  // Filtros y paginación
  filters: ClientFilters = {
    search: '',
    is_active: undefined,
    gender: '',
    sort_by: 'created_at',
    sort_order: 'desc',
    per_page: 15
  };
  
  currentPage = 1;
  totalPages = 1;
  totalItems = 0;
  
  // Estadísticas
  stats: any = {};

  constructor(
    private clientService: ClientService,
    public authService: AuthService,
    private fb: FormBuilder
  ) {
    this.clientForm = this.createClientForm();
  }

  ngOnInit(): void {
    // Verificar si el usuario es admin
    if (!this.authService.isAdmin()) {
      // Redirigir o mostrar mensaje de error
      return;
    }
    this.loadClients();
  }

  private createClientForm(): FormGroup {
    return this.fb.group({
      name: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern(/^[\d\s\+\-\(\)]+$/)]],
      address: [''],
      birth_date: [''],
      preferences: ['']
    });
  }

  loadClients(): void {
    this.loading = true;
    this.apiService.getClients({
      page: this.currentPage,
      per_page: this.itemsPerPage,
      search: this.searchTerm
    }).subscribe({
      next: (response) => {
        this.clients = response.data || response;
        this.totalItems = response.total || this.clients.length;
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading clients:', error);
        this.loading = false;
        // Datos de prueba si falla la carga
        this.clients = this.getMockClients();
      }
    });
  }

  getMockClients(): Client[] {
    return [
      {
        id: 1,
        name: 'María García',
        email: 'maria.garcia@email.com',
        phone: '+34 666 123 456',
        address: 'Calle Mayor 123, Madrid',
        birth_date: '1985-05-15',
        preferences: 'Corte y color, prefiere citas por la mañana',
        created_at: '2025-01-15T10:00:00.000000Z',
        updated_at: '2025-01-15T10:00:00.000000Z'
      },
      {
        id: 2,
        name: 'Ana López',
        email: 'ana.lopez@email.com',
        phone: '+34 677 234 567',
        address: 'Avenida de la Paz 45, Madrid',
        birth_date: '1990-08-22',
        preferences: 'Solo corte, alergica a ciertos tintes',
        created_at: '2025-01-14T15:30:00.000000Z',
        updated_at: '2025-01-14T15:30:00.000000Z'
      },
      {
        id: 3,
        name: 'Carmen Ruiz',
        email: 'carmen.ruiz@email.com',
        phone: '+34 688 345 678',
        address: 'Plaza del Sol 8, Madrid',
        birth_date: '1978-12-03',
        preferences: 'Tratamientos capilares, peinados especiales',
        created_at: '2025-01-13T09:15:00.000000Z',
        updated_at: '2025-01-13T09:15:00.000000Z'
      }
    ];
  }

  get filteredClients(): Client[] {
    if (!this.searchTerm) {
      return this.clients;
    }
    return this.clients.filter(client =>
      client.name.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
      client.email.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
      client.phone.includes(this.searchTerm)
    );
  }

  openModal(client?: Client): void {
    this.editingClient = client || null;
    this.showModal = true;
    
    if (client) {
      // Cargar datos del cliente en el formulario
      this.clientForm.patchValue({
        name: client.name,
        email: client.email,
        phone: client.phone,
        address: client.address || '',
        birth_date: client.birth_date || '',
        preferences: client.preferences || ''
      });
    } else {
      // Limpiar formulario para nuevo cliente
      this.clientForm.reset();
    }
  }

  closeModal(): void {
    this.showModal = false;
    this.editingClient = null;
    this.clientForm.reset();
  }

  saveClient(): void {
    if (this.clientForm.invalid) {
      Object.keys(this.clientForm.controls).forEach(key => {
        this.clientForm.get(key)?.markAsTouched();
      });
      return;
    }

    const formData = this.clientForm.value;
    this.loading = true;

    if (this.editingClient) {
      // Actualizar cliente existente
      const updateData: UpdateClientRequest = {
        id: this.editingClient.id,
        ...formData
      };
      
      this.apiService.updateClient(updateData).subscribe({
        next: (response) => {
          this.loadClients();
          this.closeModal();
          this.loading = false;
        },
        error: (error) => {
          console.error('Error updating client:', error);
          this.loading = false;
        }
      });
    } else {
      // Crear nuevo cliente
      const createData: CreateClientRequest = formData;
      
      this.apiService.createClient(createData).subscribe({
        next: (response) => {
          this.loadClients();
          this.closeModal();
          this.loading = false;
        },
        error: (error) => {
          console.error('Error creating client:', error);
          this.loading = false;
        }
      });
    }
  }

  deleteClient(client: Client): void {
    if (confirm(`¿Estás seguro de que quieres eliminar a ${client.name}?`)) {
      this.loading = true;
      this.apiService.deleteClient(client.id).subscribe({
        next: () => {
          this.loadClients();
          this.loading = false;
        },
        error: (error) => {
          console.error('Error deleting client:', error);
          this.loading = false;
        }
      });
    }
  }

  onSearch(): void {
    this.currentPage = 1;
    this.loadClients();
  }

  onPageChange(page: number): void {
    this.currentPage = page;
    this.loadClients();
  }

  formatDate(dateString: string | undefined): string {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES');
  }

  getFormError(fieldName: string): string {
    const field = this.clientForm.get(fieldName);
    if (field?.hasError('required')) {
      return 'Este campo es obligatorio';
    }
    if (field?.hasError('email')) {
      return 'Ingresa un email válido';
    }
    if (field?.hasError('minlength')) {
      return 'Mínimo 2 caracteres';
    }
    if (field?.hasError('pattern')) {
      return 'Formato de teléfono inválido';
    }
    return '';
  }
}
