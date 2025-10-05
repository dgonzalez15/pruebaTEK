import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from './api.service';
import { AuthService } from './auth.service';

@Component({
  selector: 'app-services',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './services.component.html',
  styleUrl: './services.component.scss'
})
export class ServicesComponent implements OnInit {
  services: any[] = [];
  loading = false;

  constructor(
    private apiService: ApiService,
    public authService: AuthService
  ) {}

  ngOnInit(): void {
    this.loadServices();
  }

  loadServices(): void {
    this.loading = true;
    this.apiService.getServices().subscribe({
      next: (response) => {
        if (response.success) {
          // Manejar formatos de respuesta
          if (response.data && Array.isArray(response.data)) {
            this.services = response.data;
          } else if (response.data && response.data.data) {
            this.services = response.data.data;
          } else {
            this.services = [];
          }
        } else {
          this.services = [];
        }
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading services:', error);
        this.services = [];
        this.loading = false;
      }
    });
  }

  formatCurrency(value: number): string {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value);
  }
}
