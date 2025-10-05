import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { Router } from '@angular/router';

interface Appointment {
  id: number;
  time: string;
  duration: string;
  clientName: string;
  serviceName: string;
  status: string;
  statusColor: string;
}

interface Activity {
  id: number;
  text: string;
  time: string;
  icon: string;
  color: string;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, DatePipe],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent implements OnInit {
  currentDate = new Date();
  todayAppointments = 8;
  totalClients = 156;
  monthlyRevenue = 15420;
  totalServices = 12;

  constructor(private router: Router) {}

  upcomingAppointments: Appointment[] = [
    {
      id: 1,
      time: '09:00',
      duration: '1h',
      clientName: 'María González',
      serviceName: 'Corte y Peinado',
      status: 'Confirmada',
      statusColor: 'success'
    },
    {
      id: 2,
      time: '10:30',
      duration: '2h',
      clientName: 'Carmen López',
      serviceName: 'Tinte y Mechas',
      status: 'Pendiente',
      statusColor: 'warning'
    },
    {
      id: 3,
      time: '13:00',
      duration: '45m',
      clientName: 'Ana Martín',
      serviceName: 'Manicure',
      status: 'Confirmada',
      statusColor: 'success'
    },
    {
      id: 4,
      time: '14:30',
      duration: '1h 30m',
      clientName: 'Isabel Ruiz',
      serviceName: 'Tratamiento Capilar',
      status: 'En Proceso',
      statusColor: 'primary'
    },
    {
      id: 5,
      time: '16:00',
      duration: '1h',
      clientName: 'Patricia Silva',
      serviceName: 'Corte y Brushing',
      status: 'Confirmada',
      statusColor: 'success'
    }
  ];

  recentActivities: Activity[] = [
    {
      id: 1,
      text: 'Nueva cita programada para María González',
      time: 'Hace 5 minutos',
      icon: 'fas fa-calendar-plus',
      color: 'success'
    },
    {
      id: 2,
      text: 'Cliente Carmen López ha cancelado su cita',
      time: 'Hace 15 minutos',
      icon: 'fas fa-calendar-times',
      color: 'danger'
    },
    {
      id: 3,
      text: 'Nuevo cliente registrado: Ana Martín',
      time: 'Hace 1 hora',
      icon: 'fas fa-user-plus',
      color: 'info'
    },
    {
      id: 4,
      text: 'Servicio completado para Isabel Ruiz',
      time: 'Hace 2 horas',
      icon: 'fas fa-check-circle',
      color: 'success'
    },
    {
      id: 5,
      text: 'Pago recibido: $850',
      time: 'Hace 3 horas',
      icon: 'fas fa-dollar-sign',
      color: 'warning'
    }
  ];

  ngOnInit(): void {
    // Aquí se pueden cargar datos reales desde el API
    this.loadDashboardData();
  }

  // Métodos de navegación para las acciones rápidas
  navigateToNewAppointment(): void {
    this.router.navigate(['/appointments']);
  }

  navigateToNewClient(): void {
    this.router.navigate(['/clients']);
  }

  navigateToNewService(): void {
    this.router.navigate(['/services']);
  }

  navigateToReports(): void {
    // Mostrar estadísticas básicas como reporte temporal
    const statsMessage = `📊 REPORTE RÁPIDO
    
🗓️ Citas de hoy: ${this.todayAppointments}
👥 Total clientes: ${this.totalClients}
💰 Ingresos del mes: $${this.monthlyRevenue.toLocaleString()}
✂️ Servicios disponibles: ${this.totalServices}

Para reportes detallados, ve a la sección de Atenciones.`;
    
    if (confirm(statsMessage + '\n\n¿Quieres ir a la sección de Atenciones para ver más detalles?')) {
      this.router.navigate(['/attentions']);
    }
  }

  // Métodos para acciones de citas
  editAppointment(appointmentId: number): void {
    console.log('Editando cita ID:', appointmentId);
    this.router.navigate(['/appointments'], { queryParams: { edit: appointmentId } });
  }

  confirmAppointment(appointmentId: number): void {
    console.log('Confirmando cita ID:', appointmentId);
    // Aquí se puede agregar lógica para confirmar la cita
  }

  private loadDashboardData(): void {
    // TODO: Implementar llamadas al API para cargar datos reales
    // Por ahora usamos datos mock
    console.log('Cargando datos del dashboard...');
  }
}
