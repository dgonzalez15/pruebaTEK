import { Component, OnInit, ViewChild, ElementRef, AfterViewInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { Chart, registerables } from 'chart.js';
import { ReportService } from '../../services/report.service';
import { ConsolidatedReport } from '../../types/reports.types';

Chart.register(...registerables);

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    MatTableModule,
    MatChipsModule
  ],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit, AfterViewInit {
  @ViewChild('servicesChart') servicesChartRef!: ElementRef<HTMLCanvasElement>;
  @ViewChild('salesChart') salesChartRef!: ElementRef<HTMLCanvasElement>;

  report: ConsolidatedReport | null = null;
  filterForm!: FormGroup;
  loading = false;
  error: string | null = null;

  servicesChart: Chart | null = null;
  salesChart: Chart | null = null;

  displayedColumns: string[] = ['position', 'client', 'appointments', 'total'];

  constructor(
    private reportService: ReportService,
    private fb: FormBuilder
  ) {}

  ngOnInit(): void {
    const today = new Date();
    const lastMonth = new Date();
    lastMonth.setMonth(lastMonth.getMonth() - 1);

    this.filterForm = this.fb.group({
      start_date: [this.formatDateForInput(lastMonth)],
      end_date: [this.formatDateForInput(today)]
    });

    this.loadReport();
  }

  ngAfterViewInit(): void {
    setTimeout(() => {
      if (this.report) {
        this.createCharts();
      }
    }, 100);
  }

  loadReport(): void {
    this.loading = true;
    this.error = null;

    const filters = {
      start_date: this.filterForm.value.start_date,
      end_date: this.filterForm.value.end_date
    };

    this.reportService.getConsolidatedReport(filters).subscribe({
      next: (data) => {
        this.report = data;
        this.loading = false;
        if (this.servicesChartRef && this.salesChartRef) {
          this.createCharts();
        }
      },
      error: (error) => {
        this.error = 'Error al cargar el dashboard. Por favor, intenta nuevamente.';
        console.error('Error:', error);
        this.loading = false;
      }
    });
  }

  applyFilters(): void {
    this.loadReport();
  }

  setQuickFilter(type: 'today' | 'week' | 'month' | 'quarter' | 'year'): void {
    const today = new Date();
    let startDate: Date;

    switch (type) {
      case 'today':
        startDate = new Date(today);
        break;
      case 'week':
        startDate = new Date(today);
        startDate.setDate(startDate.getDate() - 7);
        break;
      case 'month':
        startDate = new Date(today);
        startDate.setMonth(startDate.getMonth() - 1);
        break;
      case 'quarter':
        startDate = new Date(today);
        startDate.setMonth(startDate.getMonth() - 3);
        break;
      case 'year':
        startDate = new Date(today);
        startDate.setFullYear(startDate.getFullYear() - 1);
        break;
    }

    this.filterForm.patchValue({
      start_date: this.formatDateForInput(startDate),
      end_date: this.formatDateForInput(today)
    });

    this.loadReport();
  }

  createCharts(): void {
    if (!this.report) return;
    this.createServicesChart();
    this.createSalesChart();
  }

  createServicesChart(): void {
    if (this.servicesChart) {
      this.servicesChart.destroy();
    }

    if (!this.servicesChartRef || !this.report) return;

    const ctx = this.servicesChartRef.nativeElement.getContext('2d');
    if (!ctx) return;

    const topServices = this.report.rankings.top_services.slice(0, 5);
    const labels = topServices.map(s => s.name);
    const data = topServices.map(s => s.count);

    this.servicesChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Cantidad de Servicios',
          data: data,
          backgroundColor: '#667eea',
          borderColor: '#764ba2',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          title: {
            display: true,
            text: 'Top 5 Servicios Más Solicitados'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: 1
            }
          }
        }
      }
    });
  }

  createSalesChart(): void {
    if (this.salesChart) {
      this.salesChart.destroy();
    }

    if (!this.salesChartRef || !this.report || !this.report.trends || !Array.isArray(this.report.trends.monthly_sales)) return;

    const ctx = this.salesChartRef.nativeElement.getContext('2d');
    if (!ctx) return;

    const labels = this.report.trends.monthly_sales.map(m => m.month);
    const data = this.report.trends.monthly_sales.map(m => parseFloat(m.total));

    this.salesChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Ventas',
          data: data,
          borderColor: '#667eea',
          backgroundColor: 'rgba(102, 126, 234, 0.1)',
          fill: true,
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            position: 'bottom'
          },
          title: {
            display: true,
            text: 'Tendencia de Ventas Mensuales'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: (value) => this.formatCurrency(value as number)
            }
          }
        }
      }
    });
  }

  formatDateForInput(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  formatCurrency(value: string | number): string {
    return this.reportService.formatCurrency(value);
  }

  formatPercentage(value: number): string {
    return `${value.toFixed(2)}%`;
  }
}
