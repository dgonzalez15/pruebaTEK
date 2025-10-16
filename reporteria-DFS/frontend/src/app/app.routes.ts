import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login.component').then(m => m.LoginComponent)
  },
  {
    path: '',
    loadComponent: () => import('./components/layout/layout.component').then(m => m.LayoutComponent),
    canActivate: [authGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./pages/dashboard/dashboard.component').then(m => m.DashboardComponent)
      },
      // TODO: Descomentar cuando crees los componentes de reportes
      // {
      //   path: 'reportes/clientes-por-cita',
      //   loadComponent: () => import('./pages/reports/report-a.component').then(m => m.ReportAComponent)
      // },
      // {
      //   path: 'reportes/atenciones-servicios',
      //   loadComponent: () => import('./pages/reports/report-b.component').then(m => m.ReportBComponent)
      // },
      // {
      //   path: 'reportes/ventas-cliente',
      //   loadComponent: () => import('./pages/reports/report-c.component').then(m => m.ReportCComponent)
      // },
      // {
      //   path: 'reportes/citas-atenciones',
      //   loadComponent: () => import('./pages/reports/report-d.component').then(m => m.ReportDComponent)
      // },
      {
        path: '',
        redirectTo: 'dashboard',
        pathMatch: 'full'
      }
    ]
  },
  {
    path: '**',
    redirectTo: 'login'
  }
];
