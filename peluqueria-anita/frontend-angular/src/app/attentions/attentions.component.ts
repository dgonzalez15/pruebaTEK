import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators, FormsModule } from '@angular/forms';
import { AttentionService, Attention, AttentionFilters } from '../services/attention.service';
import { ClientService, Client } from '../services/client.service';
import { AppointmentService, Appointment } from '../services/appointment.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-attentions',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule],
  templateUrl: './attentions.component.html',
  styleUrl: './attentions.component.scss'
})
export class AttentionsComponent implements OnInit {
  attentions: Attention[] = [];
  clients: Client[] = [];
  appointments: Appointment[] = [];
  services: any[] = [];
  availableSlots: string[] = [];
  loading = false;
  showModal = false;
  showDeleteModal = false;
  editingAttention: Attention | null = null;
  deletingAttention: Attention | null = null;
  attentionForm!: FormGroup;
  
  // Filtros y paginación
  filters: AttentionFilters = {
    search: '',
    status: '',
    date: '',
    stylist_id: undefined,
    client_id: undefined,
    sort_by: 'attention_date',
    sort_order: 'desc',
    per_page: 15
  };
  
  currentPage = 1;
  totalPages = 1;
  totalItems = 0;
  
  // Estadísticas
  stats: any = {
    today: 0,
    completed: 0,
    in_progress: 0,
    started: 0,
    cancelled: 0,
    total: 0
  };

  // Estado de satisfacción y estados
  satisfactionLevels = [
    { value: 'very_unsatisfied', label: 'Muy insatisfecho', color: 'danger' },
    { value: 'unsatisfied', label: 'Insatisfecho', color: 'warning' },
    { value: 'neutral', label: 'Neutral', color: 'secondary' },
    { value: 'satisfied', label: 'Satisfecho', color: 'info' },
    { value: 'very_satisfied', label: 'Muy satisfecho', color: 'success' }
  ];

  statusTypes = [
    { value: 'started', label: 'Iniciado', color: 'primary' },
    { value: 'in_progress', label: 'En progreso', color: 'warning' },
    { value: 'completed', label: 'Completado', color: 'success' },
    { value: 'cancelled', label: 'Cancelado', color: 'danger' }
  ];

  constructor(
    private attentionService: AttentionService,
    private clientService: ClientService,
    private appointmentService: AppointmentService,
    public authService: AuthService,
    private fb: FormBuilder
  ) {
    this.initializeForm();
  }

  ngOnInit(): void {
    console.log('🚀 AttentionsComponent initializing...');
    console.log('🔍 Initial loading state:', this.loading);
    
    // Cargar datos siempre, independientemente de la autenticación
    this.loadClients();
    this.loadAppointments();
    this.loadServices(); // Agregar carga de servicios
    this.generateBasicTimeSlots(); // Generar horarios disponibles
    this.loadAttentions();
    this.loadStats();
    
    // Verificar si hay autenticación, si no hacer login automático
    if (!this.authService.isAuthenticated()) {
      console.log('❌ No authenticated, doing automatic login...');
      this.authService.login('anita@peluqueria.com', 'password123').subscribe({
        next: (response) => {
          console.log('✅ Auto login successful in attentions:', response);
        },
        error: (error) => {
          console.error('❌ Auto login failed in attentions:', error);
        }
      });
    } else {
      console.log('✅ Already authenticated');
    }
  }

  initializeForm(): void {
    this.attentionForm = this.fb.group({
      appointment_id: [''], // Hacer opcional, se puede seleccionar después
      client_id: ['', [Validators.required]],
      user_id: ['', [Validators.required]],
      service_id: ['', [Validators.required]],
      attention_date: ['', [Validators.required]],
      start_time: ['', [Validators.required]],
      end_time: [''], // Hacer opcional, se puede calcular automáticamente
      status: ['started', [Validators.required]],
      service_price: ['', [Validators.required, Validators.min(0)]],
      observations: [''],
      products_used: [''],
      tip_amount: [0, [Validators.min(0)]],
      client_satisfaction: [''],
      notes: ['']
    });

    // Listeners para calcular automáticamente end_time y service_price
    this.attentionForm.get('service_id')?.valueChanges.subscribe(serviceId => {
      this.onServiceChange(serviceId);
    });

    this.attentionForm.get('start_time')?.valueChanges.subscribe(() => {
      this.calculateEndTime();
    });
  }

  loadAttentions(): void {
    this.loading = true;
    
    console.log('🔄 Loading attentions with filters:', this.filters);
    
    this.attentionService.getAttentions(this.filters).subscribe({
      next: (response) => {
        console.log('✅ Attentions response:', response);
        if (response.success) {
          // Manejar diferentes formatos de respuesta
          if (response.data && Array.isArray(response.data)) {
            // Formato: {success: true, data: Array, pagination: Object}
            this.attentions = response.data || [];
            const pagination = (response as any).pagination || {};
            this.currentPage = pagination.current_page || 1;
            this.totalPages = pagination.last_page || 1;
            this.totalItems = pagination.total || response.data.length;
          } else if (response.data && response.data.data) {
            // Formato: {success: true, data: {data: Array, current_page: ..., etc}}
            this.attentions = response.data.data || [];
            this.currentPage = response.data.current_page || 1;
            this.totalPages = response.data.last_page || 1;
            this.totalItems = response.data.total || 0;
          } else {
            this.attentions = [];
          }
          console.log('📋 Loaded attentions:', this.attentions.length, 'items');
        } else {
          console.warn('⚠️ Attentions response not successful:', response);
          this.attentions = [];
        }
        this.loading = false;
        console.log('🏁 Attentions loading finished, loading state:', this.loading);
        
        // Actualizar estadísticas después de cargar atenciones
        this.loadStats();
      },
      error: (error) => {
        console.error('❌ Error loading attentions:', error);
        this.attentions = []; // Asegurar que siempre sea un array
        this.totalItems = 0;
        this.currentPage = 1;
        this.totalPages = 1;
        this.loading = false;
        console.log('❌ Attentions loading finished with error, loading state:', this.loading);
        
        // Actualizar estadísticas incluso en caso de error
        this.loadStats();
      }
    });
  }

  loadStats(): void {
    console.log('📊 Loading stats for attentions...');
    
    // Calcular estadísticas basándose en los datos locales
    if (this.attentions && Array.isArray(this.attentions)) {
      const today = new Date().toDateString();
      
      this.stats = {
        today: this.attentions.filter(a => 
          new Date(a.attention_date).toDateString() === today
        ).length,
        completed: this.attentions.filter(a => a.status === 'completed').length,
        in_progress: this.attentions.filter(a => a.status === 'in_progress').length,
        started: this.attentions.filter(a => a.status === 'started').length,
        cancelled: this.attentions.filter(a => a.status === 'cancelled').length,
        total: this.attentions.length
      };
      
      console.log('✅ Stats calculated locally:', this.stats);
    } else {
      // Fallback: intentar cargar desde el servicio
      this.attentionService.getAttentionStats().subscribe({
        next: (response) => {
          console.log('✅ Stats loaded from service:', response);
          if (response.success) {
            this.stats = response.data;
          } else {
            this.stats = { today: 0, completed: 0, in_progress: 0, started: 0, cancelled: 0, total: 0 };
          }
        },
        error: (error) => {
          console.error('❌ Error loading stats:', error);
          this.stats = { today: 0, completed: 0, in_progress: 0, started: 0, cancelled: 0, total: 0 };
        }
      });
    }
  }

  loadClients(): void {
    console.log('📋 Loading clients for attentions...');
    this.clientService.getClients({ is_active: true }).subscribe({
      next: (response) => {
        console.log('✅ Clients loaded successfully:', response);
        if (response.success) {
          this.clients = response.data.data || [];
          console.log('📊 Clients array:', this.clients.length, 'items');
        } else {
          this.clients = [];
        }
      },
      error: (error) => {
        console.error('❌ Error loading clients:', error);
        this.clients = []; // Asegurar que sea un array vacío
      }
    });
  }

  loadAppointments(): void {
    console.log('📅 Loading appointments for attentions...');
    this.appointmentService.getAppointments({ status: 'confirmed' }).subscribe({
      next: (response) => {
        console.log('✅ Appointments loaded successfully:', response);
        if (response.success) {
          // Manejar diferentes formatos de respuesta
          if (response.data && Array.isArray(response.data)) {
            this.appointments = response.data || [];
          } else if (response.data && response.data.data) {
            this.appointments = response.data.data || [];
          } else {
            this.appointments = [];
          }
          console.log('📊 Appointments array:', this.appointments.length, 'items');
        } else {
          this.appointments = [];
        }
      },
      error: (error) => {
        console.error('❌ Error loading appointments:', error);
        this.appointments = []; // Asegurar que sea un array vacío
      }
    });
  }

  loadServices(): void {
    // Datos estáticos para servicios mientras implementamos el endpoint
    this.services = [
      { id: 1, name: 'Corte de Cabello', price: 25, duration: 30 },
      { id: 2, name: 'Tinte', price: 65, duration: 90 },
      { id: 3, name: 'Peinado', price: 35, duration: 45 },
      { id: 4, name: 'Manicure', price: 20, duration: 30 },
      { id: 5, name: 'Pedicure', price: 25, duration: 45 },
      { id: 6, name: 'Tratamiento Capilar', price: 45, duration: 60 }
    ];
    console.log('✅ Services loaded:', this.services.length, 'items');
  }

  onServiceChange(serviceId: number): void {
    if (serviceId) {
      const selectedService = this.services.find(s => s.id === serviceId);
      if (selectedService) {
        // Actualizar el precio del servicio automáticamente como número
        this.attentionForm.patchValue({
          service_price: Number(selectedService.price)
        });
        
        // Calcular end_time si ya hay start_time
        this.calculateEndTime();
        
        console.log('🔧 Service selected:', selectedService.name, 'Price (as number):', Number(selectedService.price));
      }
    }
  }

  calculateEndTime(): void {
    const serviceId = this.attentionForm.get('service_id')?.value;
    const startTime = this.attentionForm.get('start_time')?.value;
    
    if (serviceId && startTime) {
      const selectedService = this.services.find(s => s.id === serviceId);
      if (selectedService) {
        // Convertir start_time a Date y agregar la duración
        const [hours, minutes] = startTime.split(':').map(Number);
        const startDate = new Date();
        startDate.setHours(hours, minutes, 0, 0);
        
        // Agregar la duración del servicio
        const endDate = new Date(startDate.getTime() + selectedService.duration * 60000);
        
        // Formatear como HH:MM
        const endTime = endDate.toTimeString().substring(0, 5);
        
        this.attentionForm.patchValue({
          end_time: endTime
        });
        
        console.log('🕒 End time calculated:', endTime, 'for service duration:', selectedService.duration, 'minutes');
      }
    }
  }

  onSearchChange(): void {
    this.currentPage = 1;
    this.loadAttentions();
  }

  onFilterChange(): void {
    this.currentPage = 1;
    this.loadAttentions();
  }

  openModal(attention?: Attention): void {
    console.log('🔄 Opening modal for attention:', attention ? `ID ${attention.id}` : 'Nueva atención');
    this.editingAttention = attention || null;
    this.showModal = true;
    
    if (attention) {
      // Editar atención existente
      console.log('✏️ Editing existing attention:', attention);
      this.attentionForm.patchValue({
        appointment_id: attention.appointment_id,
        client_id: attention.client_id,
        user_id: attention.user_id,
        service_id: attention.service_id,
        attention_date: attention.attention_date,
        start_time: attention.start_time,
        end_time: attention.end_time,
        status: attention.status,
        service_price: attention.service_price,
        observations: attention.observations || '',
        products_used: attention.products_used || '',
        tip_amount: attention.tip_amount || 0,
        client_satisfaction: attention.client_satisfaction || '',
        notes: attention.notes || ''
      });
    } else {
      // Nueva atención
      console.log('✨ Creating new attention');
      this.attentionForm.reset();
      
      // Obtener usuario actual desde el servicio de autenticación
      const currentUser = this.authService.getCurrentUser();
      const userId = currentUser?.id || 1; // Fallback a 1 si no hay usuario
      
      this.attentionForm.patchValue({
        status: 'started',
        attention_date: new Date().toISOString().split('T')[0],
        tip_amount: 0,
        user_id: userId,
        service_price: 0
      });
      
      console.log('🔧 Default values set for new attention:', {
        status: 'started',
        attention_date: new Date().toISOString().split('T')[0],
        user_id: userId,
        tip_amount: 0,
        service_price: 0
      });
      
      // Logging adicional para debug
      console.log('📋 Services available:', this.services);
      console.log('👥 Clients available:', this.clients.length);
    }
  }

  closeModal(): void {
    this.showModal = false;
    this.editingAttention = null;
    this.attentionForm.reset();
  }

  onSubmit(): void {
    if (this.attentionForm.valid) {
      const formData = { ...this.attentionForm.value };
      
      // Convertir explícitamente los valores numéricos para evitar problemas
      if (formData.service_price) {
        formData.service_price = Number(formData.service_price);
      }
      if (formData.tip_amount) {
        formData.tip_amount = Number(formData.tip_amount);
      }
      if (formData.user_id) {
        formData.user_id = Number(formData.user_id);
      }
      if (formData.client_id) {
        formData.client_id = Number(formData.client_id);
      }
      if (formData.service_id) {
        formData.service_id = Number(formData.service_id);
      }
      if (formData.appointment_id) {
        formData.appointment_id = Number(formData.appointment_id);
      }
      
      console.log('📤 Submitting form data with converted numbers:', formData);
      
      if (this.editingAttention) {
        // Actualizar atención existente
        this.attentionService.updateAttention(this.editingAttention.id!, formData).subscribe({
          next: (response) => {
            if (response.success) {
              this.loadAttentions();
              this.loadStats();
              this.closeModal();
            }
          },
          error: (error) => {
            console.error('Error updating attention:', error);
          }
        });
      } else {
        // Crear nueva atención
        this.attentionService.createAttention(formData).subscribe({
          next: (response) => {
            if (response.success) {
              this.loadAttentions();
              this.loadStats();
              this.closeModal();
            }
          },
          error: (error) => {
            console.error('Error creating attention:', error);
          }
        });
      }
    }
  }

  confirmDelete(attention: Attention): void {
    this.deletingAttention = attention;
    this.showDeleteModal = true;
  }

  deleteAttention(): void {
    if (this.deletingAttention) {
      this.attentionService.deleteAttention(this.deletingAttention.id!).subscribe({
        next: (response) => {
          if (response.success) {
            this.loadAttentions();
            this.loadStats();
            this.showDeleteModal = false;
            this.deletingAttention = null;
          }
        },
        error: (error) => {
          console.error('Error deleting attention:', error);
          this.showDeleteModal = false;
          this.deletingAttention = null;
        }
      });
    }
  }

  updateAttentionStatus(attention: Attention, status: string): void {
    this.attentionService.updateAttentionStatus(attention.id!, status).subscribe({
      next: (response) => {
        if (response.success) {
          this.loadAttentions();
          this.loadStats();
        }
      },
      error: (error) => {
        console.error('Error updating attention status:', error);
      }
    });
  }

  changePage(page: number): void {
    this.currentPage = page;
    this.loadAttentions();
  }

  getStatusBadgeClass(status: string): string {
    const statusObj = this.statusTypes.find(s => s.value === status);
    return `badge bg-${statusObj?.color || 'secondary'}`;
  }

  getSatisfactionBadgeClass(satisfaction?: string): string {
    if (!satisfaction) return 'badge bg-light text-dark';
    const satisfactionObj = this.satisfactionLevels.find(s => s.value === satisfaction);
    return `badge bg-${satisfactionObj?.color || 'secondary'}`;
  }

  getStatusText(status: string): string {
    const statusObj = this.statusTypes.find(s => s.value === status);
    return statusObj?.label || status;
  }

  getSatisfactionText(satisfaction?: string): string {
    if (!satisfaction) return 'No evaluado';
    const satisfactionObj = this.satisfactionLevels.find(s => s.value === satisfaction);
    return satisfactionObj?.label || satisfaction;
  }

  formatCurrency(amount?: number | string): string {
    if (!amount) return '$0';
    
    // Convertir a número si es string
    const numAmount = typeof amount === 'string' ? parseFloat(amount) : amount;
    
    // Verificar que sea un número válido
    if (isNaN(numAmount)) return '$0';
    
    // Formato simple sin separadores de miles para valores pequeños
    if (numAmount < 1000) {
      return `$${numAmount}`;
    }
    
    // Para valores grandes, usar formato con comas
    return new Intl.NumberFormat('en-US', { 
      style: 'currency', 
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(numAmount);
  }

  formatDate(date?: string): string {
    if (!date) return 'No especificada';
    return new Date(date).toLocaleDateString();
  }

  formatTime(time?: string): string {
    if (!time) return '';
    return time.substring(0, 5); // HH:MM
  }

  getFormErrors(): string {
    const errors: string[] = [];
    Object.keys(this.attentionForm.controls).forEach(key => {
      const control = this.attentionForm.get(key);
      if (control && control.invalid && control.errors) {
        const fieldErrors = Object.keys(control.errors);
        errors.push(`${key}: ${fieldErrors.join(', ')}`);
      }
    });
    return errors.length > 0 ? errors.join(' | ') : 'Sin errores';
  }

  calculateDuration(startTime?: string, endTime?: string): string {
    if (!startTime || !endTime) return '';
    
    const start = new Date(`2000-01-01T${startTime}`);
    const end = new Date(`2000-01-01T${endTime}`);
    const diffMs = end.getTime() - start.getTime();
    const diffMinutes = Math.floor(diffMs / 60000);
    
    const hours = Math.floor(diffMinutes / 60);
    const minutes = diffMinutes % 60;
    
    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    } else {
      return `${minutes}m`;
    }
  }

  getTotalAmount(attention: Attention): number {
    // Convertir explícitamente a números para evitar concatenación de strings
    const servicePrice = typeof attention.service_price === 'string' 
      ? parseFloat(attention.service_price) || 0 
      : attention.service_price || 0;
      
    const tipAmount = typeof attention.tip_amount === 'string' 
      ? parseFloat(attention.tip_amount) || 0 
      : attention.tip_amount || 0;
    
    const total = servicePrice + tipAmount;
    
    console.log('💰 Calculating total:', {
      servicePrice,
      tipAmount,
      total,
      originalServicePrice: attention.service_price,
      originalTipAmount: attention.tip_amount
    });
    
    return total;
  }

  generateBasicTimeSlots(): void {
    console.log('⏰ Generating basic time slots for attentions...');
    const slots = [];
    const start = 8; // 8:00 AM
    const end = 20; // 8:00 PM
    
    for (let hour = start; hour <= end; hour++) {
      for (let minute = 0; minute < 60; minute += 30) {
        const timeString = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
        slots.push(timeString);
      }
    }
    
    this.availableSlots = slots;
    console.log('✅ Generated', slots.length, 'time slots');
  }

  onStartTimeChange(): void {
    console.log('⏰ Start time changed in attentions');
    // Aquí se puede agregar lógica para calcular automáticamente la hora de fin
    // si es necesario
  }
}