import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators, FormsModule } from '@angular/forms';
import { AppointmentService, Appointment, AppointmentFilters } from '../services/appointment.service';
import { ClientService, Client, ApiResponse, PaginatedResponse } from '../services/client.service';
import { AuthService } from '../services/auth.service';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-appointments',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule],
  templateUrl: './appointments.component.html',
  styleUrl: './appointments.component.scss'
})
export class AppointmentsComponent implements OnInit {
  appointments: Appointment[] = [];
  clients: Client[] = [];
  services: any[] = [];
  stylists: any[] = [];
  availableSlots: string[] = [];
  loading = false;
  showModal = false;
  showDeleteModal = false;
  showRescheduleModal = false;
  editingAppointment: Appointment | null = null;
  deletingAppointment: Appointment | null = null;
  reschedulingAppointment: Appointment | null = null;
  appointmentForm!: FormGroup;
  rescheduleForm!: FormGroup;
  
  // Filtros y paginación
  filters: AppointmentFilters = {
    search: '',
    status: '',
    date: '',
    client_id: undefined,
    sort_by: 'appointment_date',
    sort_order: 'desc',
    per_page: 15
  };
  
  currentPage = 1;
  totalPages = 1;
  totalItems = 0;
  
  // Estadísticas
  stats: any = {
    today: 0,
    pending: 0,
    confirmed: 0,
    completed: 0
  };

  // Estados de citas
  statusTypes = [
    { value: 'pending', label: 'Pendiente', color: 'warning' },
    { value: 'confirmed', label: 'Confirmada', color: 'success' },
    { value: 'completed', label: 'Completada', color: 'info' },
    { value: 'cancelled', label: 'Cancelada', color: 'danger' },
    { value: 'no_show', label: 'No asistió', color: 'secondary' }
  ];

  constructor(
    private appointmentService: AppointmentService,
    private clientService: ClientService,
    public authService: AuthService,
    private fb: FormBuilder,
    private http: HttpClient
  ) {}

  ngOnInit(): void {
    console.log('🚀 AppointmentsComponent initializing...');
    console.log('🔍 Initial filters:', this.filters);
    console.log('🔍 Initial loading state:', this.loading);
    
    this.initializeForms();
    
    // Cargar datos siempre, independientemente de la autenticación
    this.loadClients();
    this.loadServices();
    this.loadStylists();
    this.generateBasicTimeSlots(); // Cargar horarios básicos al inicio
    this.loadAppointments(); // Cargar appointments al final para que las estadísticas funcionen
    
    // Verificar si hay autenticación, si no hacer login automático
    if (!this.authService.isAuthenticated()) {
      console.log('❌ No authenticated, doing automatic login...');
      this.doAutoLogin();
    } else {
      console.log('✅ Already authenticated');
    }
  }

  private doAutoLogin(): void {
    // Login automático para desarrollo - usar credenciales de la documentación
    this.authService.login('anita@peluqueria.com', 'password123').subscribe({
      next: (response) => {
        console.log('✅ Auto login successful:', response);
        // Los datos ya se están cargando en ngOnInit, no necesitamos duplicar
      },
      error: (error) => {
        console.error('❌ Auto login failed:', error);
        // Si falla el login automático, aún podemos mostrar datos públicos
        console.log('📊 Continuing without authentication...');
      }
    });
  }

  initializeForms(): void {
    this.appointmentForm = this.fb.group({
      client_id: ['', [Validators.required]],
      user_id: ['', [Validators.required]],
      services: [[], [Validators.required, this.validateServices]], // Validación personalizada para servicios
      appointment_date: ['', [Validators.required]],
      start_time: ['', [Validators.required]],
      end_time: ['', [Validators.required]],
      status: ['pending', [Validators.required]],
      total_amount: ['', [Validators.required, Validators.min(0)]],
      notes: ['']
    });

    this.rescheduleForm = this.fb.group({
      appointment_date: ['', [Validators.required]],
      start_time: ['', [Validators.required]],
      end_time: ['', [Validators.required]],
      reason: ['', [Validators.required]]
    });
  }

  loadAppointments(): void {
    this.loading = true;
    
    console.log('🔄 Loading appointments with filters:', this.filters);
    
    this.appointmentService.getAppointments(this.filters).subscribe({
      next: (response) => {
        console.log('✅ Appointments response:', response);
        if (response.success) {
          // Manejar diferentes formatos de respuesta
          if (response.data && Array.isArray(response.data)) {
            // Formato: {success: true, data: Array, pagination: Object}
            this.appointments = response.data || [];
            const pagination = (response as any).pagination || {};
            this.currentPage = pagination.current_page || 1;
            this.totalPages = pagination.last_page || 1;
            this.totalItems = pagination.total || response.data.length;
          } else if (response.data && response.data.data) {
            // Formato: {success: true, data: {data: Array, current_page: ..., etc}}
            this.appointments = response.data.data || [];
            this.currentPage = response.data.current_page || 1;
            this.totalPages = response.data.last_page || 1;
            this.totalItems = response.data.total || 0;
          } else {
            this.appointments = [];
          }
          console.log('📋 Loaded appointments:', this.appointments.length, 'items');
          console.log('📄 Pagination:', { currentPage: this.currentPage, totalPages: this.totalPages, totalItems: this.totalItems });
        } else {
          console.warn('⚠️ Appointments response not successful:', response);
          this.appointments = [];
        }
        // Cargar estadísticas después de cargar appointments
        this.loadStats();
        this.loading = false;
        console.log('🏁 Loading finished, loading state:', this.loading);
      },
      error: (error) => {
        console.error('❌ Error loading appointments:', error);
        this.appointments = []; // Asegurar que siempre sea un array
        this.totalItems = 0;
        this.currentPage = 1;
        this.totalPages = 1;
        this.loadStats(); // Cargar estadísticas vacías
        this.loading = false;
        console.log('❌ Loading finished with error, loading state:', this.loading);
      }
    });
  }

  loadStats(): void {
    // Verificar que appointments esté definido y sea un array
    if (!this.appointments || !Array.isArray(this.appointments)) {
      this.stats = {
        today: 0,
        pending: 0,
        confirmed: 0,
        completed: 0
      };
      return;
    }

    // Implementar cuando el backend tenga estadísticas de citas
    this.stats = {
      today: this.appointments.filter(a => 
        new Date(a.appointment_date).toDateString() === new Date().toDateString()
      ).length,
      pending: this.appointments.filter(a => a.status === 'pending').length,
      confirmed: this.appointments.filter(a => a.status === 'confirmed').length,
      completed: this.appointments.filter(a => a.status === 'completed').length
    };
  }

  private loadClients(): void {
    console.log('📋 Loading clients for appointments...');
    this.clientService.getClients({ is_active: true }).subscribe({
      next: (response: ApiResponse<PaginatedResponse<Client>>) => {
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

  loadAvailableSlots(date: string, stylistId?: number): void {
    console.log('⏰ Loading available slots for date:', date, 'stylist:', stylistId);
    const selectedStylistId = stylistId || this.appointmentForm.get('user_id')?.value;
    
    // Si no hay estilista seleccionado, usar horarios básicos
    if (!selectedStylistId) {
      console.log('⚠️ No stylist selected, using basic time slots');
      this.generateBasicTimeSlots();
      return;
    }
    
    this.appointmentService.getAvailableSlots(selectedStylistId, date).subscribe({
      next: (response) => {
        console.log('✅ Available slots loaded:', response);
        if (response.success && response.data && response.data.length > 0) {
          this.availableSlots = response.data;
        } else {
          console.log('📅 No slots from API, using basic time slots');
          this.generateBasicTimeSlots();
        }
      },
      error: (error) => {
        console.error('❌ Error loading available slots:', error);
        console.log('📅 Fallback to basic time slots');
        // Si falla, generar horarios básicos
        this.generateBasicTimeSlots();
      }
    });
  }

  private generateBasicTimeSlots(): void {
    console.log('🕐 Generating basic time slots...');
    this.availableSlots = [
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
      '15:00', '15:30', '16:00', '16:30', '17:00', '17:30'
    ];
    console.log('📅 Basic slots generated:', this.availableSlots);
  }

  onSearchChange(): void {
    this.currentPage = 1;
    this.loadAppointments();
  }

  onFilterChange(): void {
    this.currentPage = 1;
    this.loadAppointments();
  }

  onDateChange(): void {
    const selectedDate = this.appointmentForm.get('appointment_date')?.value;
    const selectedStylist = this.appointmentForm.get('user_id')?.value;
    
    console.log('📅 Date changed:', selectedDate, 'Stylist:', selectedStylist);
    
    if (selectedDate) {
      this.loadAvailableSlots(selectedDate);
    } else {
      // Si no hay fecha, usar horarios básicos
      this.generateBasicTimeSlots();
    }
  }

  onStylistChange(): void {
    const selectedDate = this.appointmentForm.get('appointment_date')?.value;
    const selectedStylist = this.appointmentForm.get('user_id')?.value;
    
    console.log('👨‍💼 Stylist changed:', selectedStylist, 'Date:', selectedDate);
    
    if (selectedDate && selectedStylist) {
      this.loadAvailableSlots(selectedDate);
    } else {
      // Si no hay fecha o estilista, usar horarios básicos
      this.generateBasicTimeSlots();
    }
  }

  onStartTimeChange(): void {
    console.log('⏰ Start time changed');
    // Recalcular hora de fin cuando cambie la hora de inicio
    this.calculateEndTime();
  }

  onServicesChange(): void {
    const selectedServices = this.appointmentForm.get('services')?.value || [];
    console.log('🔧 Services changed:', selectedServices);
    
    // Calcular el monto total automáticamente
    this.calculateTotalAmount();
  }

  onServiceCheckboxChange(event: any, serviceId: number): void {
    const currentServices = this.appointmentForm.get('services')?.value || [];
    
    if (event.target.checked) {
      // Agregar servicio si no está en la lista
      if (!currentServices.includes(serviceId)) {
        currentServices.push(serviceId);
      }
    } else {
      // Remover servicio de la lista
      const index = currentServices.indexOf(serviceId);
      if (index > -1) {
        currentServices.splice(index, 1);
      }
    }
    
    // Actualizar el formulario
    this.appointmentForm.patchValue({ services: currentServices });
    
    // Recalcular el monto total
    this.calculateTotalAmount();
  }

  isServiceSelected(serviceId: number): boolean {
    const selectedServices = this.appointmentForm.get('services')?.value || [];
    return selectedServices.includes(serviceId);
  }

  private calculateTotalAmount(): void {
    const selectedServiceIds = this.appointmentForm.get('services')?.value || [];
    let totalAmount = 0;
    
    selectedServiceIds.forEach((serviceId: number) => {
      const service = this.services.find(s => s.id == serviceId);
      if (service && service.price) {
        // Asegurar que el precio sea un número
        const price = typeof service.price === 'string' ? parseFloat(service.price) : service.price;
        totalAmount += price;
      }
    });
    
    console.log('💰 Calculated total amount:', totalAmount);
    // Almacenar como número, no como string
    this.appointmentForm.patchValue({ total_amount: totalAmount });
    
    // También calcular la hora de fin automáticamente
    this.calculateEndTime();
  }

  private calculateEndTime(): void {
    const startTime = this.appointmentForm.get('start_time')?.value;
    const selectedServiceIds = this.appointmentForm.get('services')?.value || [];
    
    if (!startTime || selectedServiceIds.length === 0) {
      return;
    }
    
    // Calcular duración total estimada (asumiendo 30 minutos por servicio por defecto)
    let totalMinutes = selectedServiceIds.length * 30;
    
    // Si los servicios tienen duración específica, usarla
    selectedServiceIds.forEach((serviceId: number) => {
      const service = this.services.find(s => s.id == serviceId);
      if (service && service.duration) {
        totalMinutes += service.duration;
      }
    });
    
    // Calcular hora de fin
    const [hours, minutes] = startTime.split(':').map((n: string) => parseInt(n));
    const startDate = new Date();
    startDate.setHours(hours, minutes, 0, 0);
    
    const endDate = new Date(startDate.getTime() + totalMinutes * 60000);
    const endTime = endDate.toTimeString().slice(0, 5);
    
    console.log('⏰ Calculated end time:', endTime);
    this.appointmentForm.patchValue({ end_time: endTime });
  }

  // Validador personalizado para servicios
  private validateServices(control: any) {
    const services = control.value;
    if (!services || !Array.isArray(services) || services.length === 0) {
      return { required: true };
    }
    return null;
  }

  getTodayDate(): string {
    const today = new Date();
    return today.toISOString().split('T')[0];
  }

  onRescheduleDateChange(): void {
    const selectedDate = this.rescheduleForm.get('appointment_date')?.value;
    if (selectedDate) {
      this.loadAvailableSlots(selectedDate);
    }
  }

  openModal(appointment?: Appointment): void {
    this.editingAppointment = appointment || null;
    this.showModal = true;
    
    if (appointment) {
      // Editar cita existente
      this.appointmentForm.patchValue({
        client_id: appointment.client_id,
        user_id: appointment.user_id,
        appointment_date: appointment.appointment_date,
        start_time: appointment.start_time,
        end_time: appointment.end_time,
        status: appointment.status,
        total_amount: appointment.total_amount,
        notes: appointment.notes || ''
      });
      
      this.loadAvailableSlots(appointment.appointment_date);
    } else {
      // Nueva cita
      this.appointmentForm.reset();
      this.appointmentForm.patchValue({
        status: 'pending',
        total_amount: 0
      });
    }
  }

  closeModal(): void {
    this.showModal = false;
    this.editingAppointment = null;
    this.appointmentForm.reset();
  }

  openRescheduleModal(appointment: Appointment): void {
    this.reschedulingAppointment = appointment;
    this.showRescheduleModal = true;
    
    this.rescheduleForm.patchValue({
      appointment_date: appointment.appointment_date,
      start_time: appointment.start_time,
      end_time: appointment.end_time,
      reason: ''
    });
    
    this.loadAvailableSlots(appointment.appointment_date);
  }

  closeRescheduleModal(): void {
    this.showRescheduleModal = false;
    this.reschedulingAppointment = null;
    this.rescheduleForm.reset();
  }

  onSubmit(): void {
    console.log('📝 Form submission started');
    console.log('📋 Form valid:', this.appointmentForm.valid);
    console.log('📊 Form data:', this.appointmentForm.value);
    console.log('❌ Form errors:', this.appointmentForm.errors);
    
    if (this.appointmentForm.valid) {
      const formData = { ...this.appointmentForm.value };
      
      // Transformar los servicios al formato que espera el backend
      const selectedServiceIds = formData.services || [];
      
      if (selectedServiceIds.length === 0) {
        console.error('❌ No services selected');
        // Marcar el campo services como touched para mostrar error
        this.appointmentForm.get('services')?.markAsTouched();
        return;
      }
      
      formData.services = selectedServiceIds.map((serviceId: number) => {
        const service = this.services.find(s => s.id == serviceId);
        const price = service && service.price ? 
          (typeof service.price === 'string' ? parseFloat(service.price) : service.price) : 0;
        
        return {
          service_id: serviceId,
          price: price
        };
      });
      
      // Convertir total_amount a número
      if (formData.total_amount) {
        formData.total_amount = parseFloat(formData.total_amount.toString());
      }
      
      console.log('✅ Services transformed:', formData.services);
      console.log('✅ Total amount as number:', formData.total_amount);
      
      console.log('✅ Sending transformed data:', formData);
      
      if (this.editingAppointment) {
        // Actualizar cita existente
        this.appointmentService.updateAppointment(this.editingAppointment.id!, formData).subscribe({
          next: (response) => {
            console.log('✅ Appointment updated successfully:', response);
            if (response.success) {
              this.closeModal();
              setTimeout(() => {
                this.loadAppointments();
                this.loadStats();
                console.log('✅ Update: Modal closed and data reloaded with delay');
              }, 500);
            }
          },
          error: (error) => {
            console.error('❌ Error updating appointment:', error);
          }
        });
      } else {
        // Crear nueva cita
        console.log('🆕 Creating new appointment with data:', formData);
        this.appointmentService.createAppointment(formData).subscribe({
          next: (response) => {
            console.log('✅ Appointment created successfully:', response);
            if (response.success) {
              console.log('🔄 Closing modal first...');
              this.closeModal();
              console.log('🔄 Now reloading appointments after creation...');
              // Pequeño delay para asegurar que la operación se complete
              setTimeout(() => {
                this.loadAppointments();
                this.loadStats();
                console.log('✅ Modal closed and data reloaded with delay');
              }, 500);
            } else {
              console.warn('⚠️ Creation response was not successful:', response);
            }
          },
          error: (error) => {
            console.error('❌ Error creating appointment:', error);
            console.error('❌ Error details:', error.error);
            if (error.error && error.error.errors) {
              console.error('❌ Validation errors:', error.error.errors);
            }
          }
        });
      }
    } else {
      console.log('❌ Form is invalid');
      // Marcar todos los campos como touched para mostrar errores
      Object.keys(this.appointmentForm.controls).forEach(key => {
        this.appointmentForm.get(key)?.markAsTouched();
      });
    }
  }

  onRescheduleSubmit(): void {
    if (this.rescheduleForm.valid && this.reschedulingAppointment) {
      const rescheduleData = this.rescheduleForm.value;
      
      this.appointmentService.rescheduleAppointment(
        this.reschedulingAppointment.id!,
        rescheduleData
      ).subscribe({
        next: (response) => {
          if (response.success) {
            this.loadAppointments();
            this.loadStats();
            this.closeRescheduleModal();
          }
        },
        error: (error) => {
          console.error('Error rescheduling appointment:', error);
        }
      });
    }
  }

  confirmAppointment(appointment: Appointment): void {
    this.appointmentService.confirmAppointment(appointment.id!).subscribe({
      next: (response) => {
        if (response.success) {
          this.loadAppointments();
          this.loadStats();
        }
      },
      error: (error) => {
        console.error('Error confirming appointment:', error);
      }
    });
  }

  updateAppointmentStatus(appointment: Appointment, status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled' | 'no_show'): void {
    const updateData = { status };
    
    this.appointmentService.updateAppointment(appointment.id!, updateData).subscribe({
      next: (response) => {
        if (response.success) {
          this.loadAppointments();
          this.loadStats();
        }
      },
      error: (error) => {
        console.error('Error updating appointment status:', error);
      }
    });
  }

  updateStatusFromDropdown(event: Event, appointment: Appointment, status: string): void {
    event.preventDefault();
    this.updateAppointmentStatus(appointment, status as any);
  }

  confirmDelete(appointment: Appointment): void {
    this.deletingAppointment = appointment;
    this.showDeleteModal = true;
  }

  deleteAppointment(): void {
    if (this.deletingAppointment) {
      this.appointmentService.deleteAppointment(this.deletingAppointment.id!).subscribe({
        next: (response) => {
          if (response.success) {
            this.loadAppointments();
            this.loadStats();
            this.showDeleteModal = false;
            this.deletingAppointment = null;
          }
        },
        error: (error) => {
          console.error('Error deleting appointment:', error);
          this.showDeleteModal = false;
          this.deletingAppointment = null;
        }
      });
    }
  }

  changePage(page: number): void {
    this.currentPage = page;
    this.loadAppointments();
  }

  getStatusBadgeClass(status: string): string {
    const statusObj = this.statusTypes.find(s => s.value === status);
    return `badge bg-${statusObj?.color || 'secondary'}`;
  }

  getStatusText(status: string): string {
    const statusObj = this.statusTypes.find(s => s.value === status);
    return statusObj?.label || status;
  }

  formatDate(date?: string): string {
    if (!date) return 'No especificada';
    return new Date(date).toLocaleDateString();
  }

  formatTime(time?: string): string {
    if (!time) return '';
    return time.substring(0, 5); // HH:MM
  }

  isToday(date?: string): boolean {
    if (!date) return false;
    return new Date(date).toDateString() === new Date().toDateString();
  }

  isPast(date?: string, time?: string): boolean {
    if (!date) return false;
    const appointmentDateTime = new Date(`${date}T${time || '00:00'}`);
    return appointmentDateTime < new Date();
  }

  searchAppointmentsByClient(clientName: string): void {
    this.appointmentService.searchAppointmentsByClient(clientName).subscribe({
      next: (response) => {
        if (response.success) {
          this.appointments = response.data.data || response.data;
          // Actualizar estadísticas basadas en los resultados filtrados
          this.loadStats();
        }
      },
      error: (error) => {
        console.error('Error searching appointments by client:', error);
      }
    });
  }

  private loadServices(): void {
    console.log('🔧 Loading services...');
    this.http.get<any>(`${environment.apiUrl}/services`).subscribe({
      next: (response) => {
        console.log('✅ Services loaded:', response);
        if (response.success) {
          this.services = response.data.data || response.data || [];
          console.log('📊 Services array:', this.services.length, 'items');
        } else {
          this.services = [];
        }
      },
      error: (error) => {
        console.error('❌ Error loading services:', error);
        this.services = []; // Asegurar que sea un array vacío
      }
    });
  }

  private loadStylists(): void {
    console.log('👨‍💼 Loading stylists...');
    this.http.get<any>(`${environment.apiUrl}/stylists`).subscribe({
      next: (response) => {
        console.log('✅ Stylists loaded:', response);
        if (response.success) {
          this.stylists = response.data.data || response.data || [];
          console.log('📊 Stylists array:', this.stylists.length, 'items');
        } else {
          this.stylists = [];
        }
      },
      error: (error) => {
        console.error('❌ Error loading stylists:', error);
        this.stylists = []; // Asegurar que sea un array vacío
      }
    });
  }
}
