<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\Client;
use App\Models\Service;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * Get dashboard statistics.
     */
    public function stats(Request $request): JsonResponse
    {
        $period = $request->get('period', 'month'); // day, week, month, year
        $date = $request->get('date', now()->toDateString());

        // Definir rango de fechas según el período
        switch ($period) {
            case 'day':
                $startDate = Carbon::parse($date)->startOfDay();
                $endDate = Carbon::parse($date)->endOfDay();
                break;
            case 'week':
                $startDate = Carbon::parse($date)->startOfWeek();
                $endDate = Carbon::parse($date)->endOfWeek();
                break;
            case 'year':
                $startDate = Carbon::parse($date)->startOfYear();
                $endDate = Carbon::parse($date)->endOfYear();
                break;
            case 'month':
            default:
                $startDate = Carbon::parse($date)->startOfMonth();
                $endDate = Carbon::parse($date)->endOfMonth();
                break;
        }

        // Estadísticas generales
        $totalClients = Client::count();
        $totalServices = Service::where('is_active', true)->count();
        $totalRevenue = Payment::whereBetween('created_at', [$startDate, $endDate])
            ->where('status', 'completed')
            ->sum('amount');
        
        $appointmentsInPeriod = Appointment::whereBetween('appointment_date', [
            $startDate->toDateString(), 
            $endDate->toDateString()
        ]);

        $totalAppointments = $appointmentsInPeriod->count();
        $completedAppointments = $appointmentsInPeriod->where('status', 'completed')->count();
        $pendingAppointments = $appointmentsInPeriod->where('status', 'pending')->count();
        $confirmedAppointments = $appointmentsInPeriod->where('status', 'confirmed')->count();

        // Citas de hoy
        $todayAppointments = Appointment::with(['client', 'stylist'])
            ->whereDate('appointment_date', today())
            ->orderBy('start_time')
            ->get();

        // Próximas citas (siguientes 7 días)
        $upcomingAppointments = Appointment::with(['client', 'stylist'])
            ->whereBetween('appointment_date', [
                now()->addDay()->toDateString(),
                now()->addDays(7)->toDateString()
            ])
            ->whereIn('status', ['pending', 'confirmed'])
            ->orderBy('appointment_date')
            ->orderBy('start_time')
            ->limit(10)
            ->get();

        // Servicios más populares
        $popularServices = Service::withCount(['appointmentDetails' => function ($query) use ($startDate, $endDate) {
                $query->whereHas('appointment', function ($q) use ($startDate, $endDate) {
                    $q->whereBetween('appointment_date', [
                        $startDate->toDateString(), 
                        $endDate->toDateString()
                    ])->where('status', 'completed');
                });
            }])
            ->where('is_active', true)
            ->orderBy('appointment_details_count', 'desc')
            ->limit(5)
            ->get();

        // Clientes más frecuentes
        $topClients = Client::withCount(['appointments' => function ($query) use ($startDate, $endDate) {
                $query->whereBetween('appointment_date', [
                    $startDate->toDateString(), 
                    $endDate->toDateString()
                ])->where('status', 'completed');
            }])
            ->get()
            ->filter(function ($client) {
                return $client->appointments_count > 0;
            })
            ->sortByDesc('appointments_count')
            ->take(5)
            ->values();

        // Ingresos por día (para gráficos)
        $dailyRevenue = [];
        $currentDate = $startDate->copy();
        
        while ($currentDate <= $endDate) {
            $dayRevenue = Payment::whereDate('created_at', $currentDate->toDateString())
                ->where('status', 'completed')
                ->sum('amount');
            
            $dailyRevenue[] = [
                'date' => $currentDate->format('Y-m-d'),
                'revenue' => $dayRevenue,
                'day_name' => $currentDate->format('l')
            ];
            
            $currentDate->addDay();
        }

        // Estadísticas de estilistas
        $stylistStats = User::where('role', 'stylist')
            ->withCount(['appointments' => function ($query) use ($startDate, $endDate) {
                $query->whereBetween('appointment_date', [
                    $startDate->toDateString(), 
                    $endDate->toDateString()
                ])->where('status', 'completed');
            }])
            ->with(['appointments' => function ($query) use ($startDate, $endDate) {
                $query->whereBetween('appointment_date', [
                    $startDate->toDateString(), 
                    $endDate->toDateString()
                ])->where('status', 'completed');
            }])
            ->get()
            ->map(function ($stylist) {
                return [
                    'id' => $stylist->id,
                    'name' => $stylist->name,
                    'appointments_count' => $stylist->appointments_count,
                    'total_revenue' => $stylist->appointments->sum('total_amount'),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'period' => $period,
                'date_range' => [
                    'start' => $startDate->toDateString(),
                    'end' => $endDate->toDateString()
                ],
                'general_stats' => [
                    'total_clients' => $totalClients,
                    'total_services' => $totalServices,
                    'total_revenue' => $totalRevenue,
                    'total_appointments' => $totalAppointments,
                    'completed_appointments' => $completedAppointments,
                    'pending_appointments' => $pendingAppointments,
                    'confirmed_appointments' => $confirmedAppointments,
                    'completion_rate' => $totalAppointments > 0 ? 
                        round(($completedAppointments / $totalAppointments) * 100, 2) : 0
                ],
                'today_appointments' => $todayAppointments,
                'upcoming_appointments' => $upcomingAppointments,
                'popular_services' => $popularServices,
                'top_clients' => $topClients,
                'daily_revenue' => $dailyRevenue,
                'stylist_stats' => $stylistStats
            ]
        ]);
    }

    /**
     * Get monthly overview.
     */
    public function monthlyOverview(Request $request): JsonResponse
    {
        $year = $request->get('year', now()->year);
        $month = $request->get('month', now()->month);

        $startDate = Carbon::createFromDate($year, $month, 1)->startOfMonth();
        $endDate = $startDate->copy()->endOfMonth();

        // Citas por día del mes
        $dailyAppointments = [];
        $currentDate = $startDate->copy();

        while ($currentDate <= $endDate) {
            $dayAppointments = Appointment::whereDate('appointment_date', $currentDate->toDateString())
                ->get()
                ->groupBy('status')
                ->map(function ($appointments) {
                    return $appointments->count();
                });

            $dailyAppointments[] = [
                'date' => $currentDate->format('Y-m-d'),
                'day' => $currentDate->day,
                'day_name' => $currentDate->format('D'),
                'appointments' => $dayAppointments->toArray(),
                'total' => $dayAppointments->sum()
            ];

            $currentDate->addDay();
        }

        // Resumen del mes
        $monthlyStats = [
            'total_appointments' => Appointment::whereBetween('appointment_date', [
                $startDate->toDateString(), 
                $endDate->toDateString()
            ])->count(),
            'total_revenue' => Payment::whereBetween('created_at', [$startDate, $endDate])
                ->where('status', 'completed')
                ->sum('amount'),
            'new_clients' => Client::whereBetween('created_at', [$startDate, $endDate])->count(),
            'average_daily_appointments' => 0
        ];

        if (count($dailyAppointments) > 0) {
            $monthlyStats['average_daily_appointments'] = round(
                collect($dailyAppointments)->avg('total'), 1
            );
        }

        return response()->json([
            'success' => true,
            'data' => [
                'year' => $year,
                'month' => $month,
                'month_name' => $startDate->format('F'),
                'monthly_stats' => $monthlyStats,
                'daily_appointments' => $dailyAppointments
            ]
        ]);
    }

    /**
     * Get quick stats for widgets.
     */
    public function quickStats(): JsonResponse
    {
        $today = now()->toDateString();
        $thisWeek = [now()->startOfWeek()->toDateString(), now()->endOfWeek()->toDateString()];
        $thisMonth = [now()->startOfMonth()->toDateString(), now()->endOfMonth()->toDateString()];

        $stats = [
            'today' => [
                'appointments' => Appointment::whereDate('appointment_date', $today)->count(),
                'completed' => Appointment::whereDate('appointment_date', $today)
                    ->where('status', 'completed')->count(),
                'revenue' => Payment::whereDate('created_at', $today)
                    ->where('status', 'completed')->sum('amount')
            ],
            'this_week' => [
                'appointments' => Appointment::whereBetween('appointment_date', $thisWeek)->count(),
                'revenue' => Payment::whereBetween('created_at', $thisWeek)
                    ->where('status', 'completed')->sum('amount'),
                'new_clients' => Client::whereBetween('created_at', $thisWeek)->count()
            ],
            'this_month' => [
                'appointments' => Appointment::whereBetween('appointment_date', $thisMonth)->count(),
                'revenue' => Payment::whereBetween('created_at', $thisMonth)
                    ->where('status', 'completed')->sum('amount'),
                'new_clients' => Client::whereBetween('created_at', $thisMonth)->count()
            ]
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }
}