
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTableModule } from '@angular/material/table';
import { FormBuilder, FormGroup } from '@angular/forms';
import { ReportService } from '../../services/report.service';
import { ClientSalesReport, GeneralSummary } from '../../types/reports.types';

@Component({
  selector: 'app-report-c',
  templateUrl: './report-c.component.html',
  styleUrls: ['./report-c.component.scss'],
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
    MatTableModule
  ]
})
export class ReportCComponent implements OnInit {
  filterForm!: FormGroup;
  loading = false;
  error: string | null = null;
  data: ClientSalesReport[] = [];
  summary: GeneralSummary | null = null;
  displayedColumns: string[] = ['client', 'total_appointments', 'total_services', 'total_spent'];

  constructor(private fb: FormBuilder, private reportService: ReportService) {}

  ngOnInit(): void {
    const today = new Date();
    const lastMonth = new Date();
    lastMonth.setMonth(lastMonth.getMonth() - 1);
    this.filterForm = this.fb.group({
      start_date: [this.formatDateForInput(lastMonth)],
      end_date: [this.formatDateForInput(today)]
    });
    this.loadData();
  }

  formatDateForInput(date: Date): string {
    return date.toISOString().slice(0, 10);
  }

  loadData(): void {
    this.loading = true;
    this.error = null;
    const filters = this.filterForm.value;
    this.reportService.getClientSales(filters).subscribe({
      next: (res) => {
        this.data = res.data;
        this.summary = res.general_summary;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Error al cargar el reporte';
        this.loading = false;
      }
    });
  }

  applyFilters(): void {
    this.loadData();
  }

  exportCSV(): void {
    // Implementar exportación CSV si es necesario
  }
}
