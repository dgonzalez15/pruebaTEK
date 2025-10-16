import { Component } from '@angular/core';
import { ReportAComponent } from './report-a.component';
import { ReportBComponent } from './report-b.component';
import { ReportCComponent } from './report-c.component';
import { ReportDComponent } from './report-d.component';
import { CommonModule } from '@angular/common';
import { MatTabsModule } from '@angular/material/tabs';
@Component({
  standalone: true,
  imports: [
    CommonModule,
    MatTabsModule,
    ReportAComponent,
    ReportBComponent,
    ReportCComponent,
    ReportDComponent
  ],
  templateUrl: './reports.component.html',
  styleUrls: ['./reports.component.scss']
})
export class ReportsComponent {
  selectedTab = 0;
}
