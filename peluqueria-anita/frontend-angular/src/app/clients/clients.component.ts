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
  clientForm!: FormGroup;
  
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
    this.initializeForm();
  }

  ngOnInit(): void {
    // Verificar si hay autenticación, si no hacer login automático
    if (!this.authService.isAuthenticated()) {
      console.log('No authenticated, doing automatic login...');
      this.doAutoLogin();
    } else {
      this.loadClients();
      this.loadStats();
    }
  }

  private doAutoLogin(): void {
    // Login automático para desarrollo - usar credenciales de la documentación
    this.authService.login('anita@peluqueria.com', 'password123').subscribe({
      next: (response) => {
        console.log('✅ Auto login successful:', response);
        this.loadClients();
        this.loadStats();
      },
      error: (error) => {
        console.error('❌ Auto login failed:', error);
        // Si falla el login automático, redirigir al login
        // window.location.href = '/login';
      }
    });
  }

  initializeForm(): void {
    this.clientForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.email]],
      phone: ['', [Validators.required]],
      address: [''],
      birth_date: [''],
      gender: [''],
      notes: [''],
      is_active: [true]
    });
  }

  loadClients(): void {
    this.loading = true;
    
    this.clientService.getClients(this.filters).subscribe({
      next: (response) => {
        if (response.success) {
          this.clients = response.data.data;
          this.currentPage = response.data.current_page;
          this.totalPages = response.data.last_page;
          this.totalItems = response.data.total;
        }
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading clients:', error);
        this.loading = false;
      }
    });
  }

  loadStats(): void {
    this.clientService.getClientStats().subscribe({
      next: (response) => {
        if (response.success) {
          this.stats = response.data;
        }
      },
      error: (error) => {
        console.error('Error loading stats:', error);
      }
    });
  }

  onSearchChange(): void {
    this.currentPage = 1;
    this.loadClients();
  }

  onFilterChange(): void {
    this.currentPage = 1;
    this.loadClients();
  }

  openModal(client?: Client): void {
    console.log('Opening modal for client:', client);
    this.editingClient = client || null;
    this.showModal = true;
    
    if (client) {
      // Editar cliente existente
      console.log('Editing existing client');
      this.clientForm.patchValue({
        name: client.name,
        email: client.email || '',
        phone: client.phone,
        address: client.address || '',
        birth_date: client.birth_date || '',
        gender: client.gender || '',
        notes: client.notes || '',
        is_active: client.is_active !== false
      });
    } else {
      // Nuevo cliente
      console.log('Creating new client');
      this.clientForm.reset();
      this.clientForm.patchValue({
        is_active: true
      });
    }
    
    console.log('Form after modal open:', this.clientForm.value);
    console.log('Form valid after modal open:', this.clientForm.valid);
  }

  closeModal(): void {
    this.showModal = false;
    this.editingClient = null;
    this.clientForm.reset();
  }

  onSubmit(): void {
    console.log('🎯 onSubmit called - Form submit started');
    console.log('📋 Form valid:', this.clientForm.valid);
    console.log('💾 Form value:', this.clientForm.value);
    
    if (this.clientForm.valid) {
      const formData = this.clientForm.value;
      console.log('✅ Form is valid, proceeding with submission');
      
      if (this.editingClient) {
        // Actualizar cliente existente
        console.log('🔄 Updating existing client:', this.editingClient.id);
        this.clientService.updateClient(this.editingClient.id!, formData).subscribe({
          next: (response) => {
            console.log('✅ Update response:', response);
            if (response.success) {
              console.log('🎉 Client updated successfully');
              this.loadClients();
              this.closeModal();
            } else {
              console.error('❌ Update failed:', response);
            }
          },
          error: (error) => {
            console.error('❌ Error updating client:', error);
          }
        });
      } else {
        // Crear nuevo cliente
        console.log('📝 Creating new client with data:', formData);
        this.clientService.createClient(formData).subscribe({
          next: (response) => {
            console.log('✅ Create response:', response);
            if (response.success) {
              console.log('🎉 Client created successfully');
              this.loadClients();
              this.loadStats();
              this.closeModal();
            } else {
              console.error('❌ Create failed:', response);
            }
          },
          error: (error) => {
            console.error('❌ Error creating client:', error);
            // Para debugging, mostrar el error completo
            console.error('Full error object:', error);
            if (error.error) {
              console.error('Error message:', error.error.message);
              console.error('Error details:', error.error);
            }
          }
        });
      }
    } else {
      console.log('❌ Form is invalid, checking errors...');
      console.log('Form errors:', this.getFormErrors());
      // Marcar todos los campos como tocados para mostrar errores
      Object.keys(this.clientForm.controls).forEach(key => {
        this.clientForm.get(key)?.markAsTouched();
      });
    }
  }

  confirmDelete(client: Client): void {
    this.deletingClient = client;
    this.showDeleteModal = true;
  }

  deleteClient(): void {
    if (this.deletingClient) {
      console.log('🗑️ Deleting client:', this.deletingClient.id);
      this.clientService.deleteClient(this.deletingClient.id!).subscribe({
        next: (response) => {
          console.log('✅ Delete response:', response);
          if (response.success) {
            console.log('🎉 Client deleted successfully');
            this.loadClients();
            this.loadStats();
            this.showDeleteModal = false;
            this.deletingClient = null;
          }
        },
        error: (error) => {
          console.error('❌ Error deleting client:', error);
          this.showDeleteModal = false;
          this.deletingClient = null;
        }
      });
    }
  }

  toggleClientStatus(client: Client): void {
    this.clientService.toggleClientStatus(client.id!).subscribe({
      next: (response) => {
        if (response.success) {
          this.loadClients();
          this.loadStats();
        }
      },
      error: (error) => {
        console.error('Error toggling client status:', error);
      }
    });
  }

  viewClientAppointments(client: Client): void {
    // Aquí se podría abrir un modal o navegar a una página de historial
    console.log('Ver historial de citas para:', client.name);
  }

  changePage(page: number): void {
    this.currentPage = page;
    this.loadClients();
  }

  // Método de debugging para ver errores del formulario
  getFormErrors(): any {
    let formErrors: any = {};
    Object.keys(this.clientForm.controls).forEach(key => {
      const control = this.clientForm.get(key);
      if (control && !control.valid && control.touched) {
        formErrors[key] = control.errors;
      }
    });
    return formErrors;
  }

  // Método de prueba para verificar el formulario
  testForm(): void {
    console.log('🧪 TEST: Formulario de cliente');
    console.log('Form valid:', this.clientForm.valid);
    console.log('Form value:', this.clientForm.value);
    console.log('Form errors:', this.getFormErrors());
    
    // Llenar el formulario con datos de prueba
    this.clientForm.patchValue({
      name: 'Cliente de Prueba ' + Date.now(),
      email: 'test' + Date.now() + '@example.com',
      phone: '555-' + Math.floor(Math.random() * 10000),
      address: 'Dirección de Prueba 123',
      gender: 'other',
      is_active: true
    });
    
    console.log('Form después de llenar:', this.clientForm.value);
    console.log('Form valid después de llenar:', this.clientForm.valid);
  }

  getStatusBadgeClass(isActive: boolean): string {
    return isActive ? 'badge bg-success' : 'badge bg-secondary';
  }

  getGenderText(gender?: string): string {
    switch (gender) {
      case 'male': return 'Masculino';
      case 'female': return 'Femenino';
      case 'other': return 'Otro';
      default: return 'No especificado';
    }
  }

  formatCurrency(amount?: number): string {
    return amount ? `$${amount.toFixed(2)}` : '$0.00';
  }

  formatDate(date?: string): string {
    if (!date) return 'No especificada';
    return new Date(date).toLocaleDateString();
  }
}