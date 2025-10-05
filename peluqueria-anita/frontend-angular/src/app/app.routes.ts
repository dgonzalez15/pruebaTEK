import { Routes } from '@angular/router';
import { LoginComponent } from './auth/login/login.component';
import { RegisterComponent } from './auth/register/register.component';
import { DashboardComponent } from './dashboard/dashboard.component';
import { ClientsComponent } from './clients/clients.component';
import { AppointmentsComponent } from './appointments/appointments.component';
import { AttentionsComponent } from './attentions/attentions.component';
import { ServicesComponent } from './services/services.component';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { 
    path: 'dashboard', 
    component: DashboardComponent, 
    canActivate: [authGuard] 
  },
  { 
    path: 'appointments', 
    component: AppointmentsComponent, 
    canActivate: [authGuard] 
  },
  { 
    path: 'attentions', 
    component: AttentionsComponent, 
    canActivate: [authGuard] 
  },
  { 
    path: 'clients', 
    component: ClientsComponent, 
    canActivate: [authGuard],
    data: { role: 'admin' } // Solo administradores pueden gestionar clientes
  },
  { 
    path: 'services', 
    component: ServicesComponent, 
    canActivate: [authGuard],
    data: { role: 'admin' } // Solo administradores pueden gestionar servicios
  },
  { path: '**', redirectTo: '/login' }
];
