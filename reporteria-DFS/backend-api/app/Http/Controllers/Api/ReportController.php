<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Person;
use App\Models\Cite;
use App\Models\Attention;
use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * ReportController
 * Sistema de Reportería DFS
 */
class ReportController extends Controller
{
    /**
     * REPORTE A: Listado de Personas por Cita
     */
    public function personasPorCita(Request $request)
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');
        $status = $request->input('status');

        $query = Person::with(['cites' => function ($query) use ($startDate, $endDate, $status) {
            if ($startDate && $endDate) {
                $query->whereBetween('date', [$startDate, $endDate]);
            }
            if ($status) {
                $query->where('status', $status);
            }
            $query->orderBy('date', 'desc');
        }]);

        $personas = $query->get();

        $data = $personas->map(function ($persona) {
            return [
                'id' => $persona->id,
                'documento' => $persona->document,
                'nombre_completo' => $persona->full_name,
                'email' => $persona->email,
                'telefono' => $persona->phone,
                'total_citas' => $persona->cites->count(),
                'citas' => $persona->cites->map(function ($cita) {
                    return [
                        'id' => $cita->id,
                        'fecha' => $cita->date->format('Y-m-d'),
                        'hora_llegada' => $cita->time_arrival ? $cita->time_arrival->format('H:i') : null,
                        'estado' => $cita->status,
                        'monto_atencion' => number_format($cita->amount_attention, 2),
                        'total_servicio' => number_format($cita->total_service, 2)
                    ];
                })
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
            'total_personas' => $personas->count()
        ]);
    }

    /**
     * REPORTE B: Personas con Atenciones y Servicios
     */
    public function personasAtencionesServicios(Request $request)
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');

        $query = Person::with(['cites.attentions.service']);

        if ($startDate && $endDate) {
            $query->whereHas('cites', function ($q) use ($startDate, $endDate) {
                $q->whereBetween('date', [$startDate, $endDate]);
            });
        }

        $personas = $query->get();

        $data = $personas->map(function ($persona) use ($startDate, $endDate) {
            $citas = $persona->cites;
            if ($startDate && $endDate) {
                $citas = $citas->whereBetween('date', [$startDate, $endDate]);
            }

            $atenciones = [];
            foreach ($citas as $cita) {
                foreach ($cita->attentions as $atencion) {
                    $atenciones[] = [
                        'cita_id' => $cita->id,
                        'fecha_cita' => $cita->date->format('Y-m-d'),
                        'fecha_atencion' => $atencion->date->format('Y-m-d'),
                        'servicio' => $atencion->service->name,
                        'precio' => number_format($atencion->price_service, 2)
                    ];
                }
            }

            return [
                'id' => $persona->id,
                'documento' => $persona->document,
                'nombre_completo' => $persona->full_name,
                'email' => $persona->email,
                'telefono' => $persona->phone,
                'total_atenciones' => count($atenciones),
                'atenciones' => $atenciones
            ];
        })->filter(function ($persona) {
            return $persona['total_atenciones'] > 0;
        })->values();

        return response()->json([
            'success' => true,
            'data' => $data,
            'total_personas' => $data->count()
        ]);
    }

    /**
     * REPORTE C: Citas y Ventas por Persona
     */
    public function citasVentasPorPersona(Request $request)
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');

        $query = Person::with(['cites' => function ($query) use ($startDate, $endDate) {
            if ($startDate && $endDate) {
                $query->whereBetween('date', [$startDate, $endDate]);
            }
            $query->where('status', 'completed');
        }]);

        $personas = $query->get();

        $data = $personas->map(function ($persona) {
            $totalVentas = $persona->cites->sum('total_service');
            $totalCitas = $persona->cites->count();

            return [
                'id' => $persona->id,
                'documento' => $persona->document,
                'nombre_completo' => $persona->full_name,
                'email' => $persona->email,
                'telefono' => $persona->phone,
                'total_citas' => $totalCitas,
                'total_ventas' => number_format($totalVentas, 2),
                'promedio_por_cita' => $totalCitas > 0 ? number_format($totalVentas / $totalCitas, 2) : '0.00'
            ];
        })->filter(function ($persona) {
            return $persona['total_citas'] > 0;
        })->values();

        return response()->json([
            'success' => true,
            'data' => $data,
            'total_personas' => $data->count(),
            'suma_total_ventas' => number_format($data->sum(function ($p) {
                return floatval(str_replace(',', '', $p['total_ventas']));
            }), 2)
        ]);
    }

    /**
     * REPORTE D: Citas y Atenciones
     */
    public function citasYAtenciones(Request $request)
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');
        $status = $request->input('status');

        $query = Cite::with(['person', 'attentions.service']);

        if ($startDate && $endDate) {
            $query->whereBetween('date', [$startDate, $endDate]);
        }

        if ($status) {
            $query->where('status', $status);
        }

        $citas = $query->orderBy('date', 'desc')->get();

        $data = $citas->map(function ($cita) {
            return [
                'id' => $cita->id,
                'fecha' => $cita->date->format('Y-m-d'),
                'hora_llegada' => $cita->time_arrival ? $cita->time_arrival->format('H:i') : null,
                'estado' => $cita->status,
                'persona' => [
                    'id' => $cita->person->id,
                    'documento' => $cita->person->document,
                    'nombre_completo' => $cita->person->full_name,
                    'email' => $cita->person->email,
                    'telefono' => $cita->person->phone
                ],
                'monto_atencion' => number_format($cita->amount_attention, 2),
                'total_servicio' => number_format($cita->total_service, 2),
                'atenciones' => $cita->attentions->map(function ($atencion) {
                    return [
                        'id' => $atencion->id,
                        'fecha' => $atencion->date->format('Y-m-d'),
                        'servicio' => $atencion->service->name,
                        'precio' => number_format($atencion->price_service, 2)
                    ];
                })
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
            'total_citas' => $citas->count(),
            'suma_total_servicios' => number_format($citas->sum('total_service'), 2)
        ]);
    }

    /**
     * REPORTE CONSOLIDADO - Dashboard
     */
    public function reporteConsolidado(Request $request)
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');

        $totalPersonas = Person::count();

        $queryCitas = Cite::query();
        if ($startDate && $endDate) {
            $queryCitas->whereBetween('date', [$startDate, $endDate]);
        }
        $totalCitas = $queryCitas->count();

        $citasPorEstado = Cite::when($startDate && $endDate, function ($q) use ($startDate, $endDate) {
            return $q->whereBetween('date', [$startDate, $endDate]);
        })->select('status', DB::raw('count(*) as total'))->groupBy('status')->get();

        $queryAtenciones = Attention::query();
        if ($startDate && $endDate) {
            $queryAtenciones->whereBetween('date', [$startDate, $endDate]);
        }
        $totalAtenciones = $queryAtenciones->count();

        $queryVentas = Cite::query();
        if ($startDate && $endDate) {
            $queryVentas->whereBetween('date', [$startDate, $endDate]);
        }
        $totalVentas = $queryVentas->where('status', 'completed')->sum('total_service');

        $serviciosMasSolicitados = Service::withCount(['attentions' => function ($query) use ($startDate, $endDate) {
            if ($startDate && $endDate) {
                $query->whereBetween('date', [$startDate, $endDate]);
            }
        }])->get()
            ->filter(function ($service) {
                return $service->attentions_count > 0;
            })
            ->sortByDesc('attentions_count')
            ->take(10)
            ->map(function ($service) {
                return [
                    'servicio' => $service->name,
                    'total_atenciones' => $service->attentions_count
                ];
            })->values();

        $personasConMasCitas = Person::withCount(['cites' => function ($query) use ($startDate, $endDate) {
            if ($startDate && $endDate) {
                $query->whereBetween('date', [$startDate, $endDate]);
            }
        }])->get()
            ->filter(function ($persona) {
                return $persona->cites_count > 0;
            })
            ->sortByDesc('cites_count')
            ->take(10)
            ->map(function ($persona) {
                return [
                    'nombre_completo' => $persona->full_name,
                    'documento' => $persona->document,
                    'total_citas' => $persona->cites_count
                ];
            })->values();

        // Calcular días del periodo
        $days = $startDate && $endDate ? now()->parse($startDate)->diffInDays(now()->parse($endDate)) + 1 : 30;
        
        // Calcular tasas y promedios
        $citasCompletadas = Cite::when($startDate && $endDate, function ($q) use ($startDate, $endDate) {
            return $q->whereBetween('date', [$startDate, $endDate]);
        })->where('status', 'completed')->count();
        
        $citasCanceladas = Cite::when($startDate && $endDate, function ($q) use ($startDate, $endDate) {
            return $q->whereBetween('date', [$startDate, $endDate]);
        })->where('status', 'cancelled')->count();
        
        $completionRate = $totalCitas > 0 ? ($citasCompletadas / $totalCitas) * 100 : 0;
        $cancellationRate = $totalCitas > 0 ? ($citasCanceladas / $totalCitas) * 100 : 0;
        
        // Formatear citas por estado como objeto
        $byStatus = [];
        foreach ($citasPorEstado as $estado) {
            $byStatus[$estado->status] = $estado->total;
        }

        return response()->json([
            'success' => true,
            'data' => [
                'period' => [
                    'start_date' => $startDate ?? now()->subMonth()->format('Y-m-d'),
                    'end_date' => $endDate ?? now()->format('Y-m-d'),
                    'days' => $days
                ],
                'metrics' => [
                    'clients' => [
                        'total' => $totalPersonas,
                        'active' => $totalPersonas,
                        'inactive' => 0,
                        'new_in_period' => 0
                    ],
                    'appointments' => [
                        'total' => $totalCitas,
                        'completed' => $citasCompletadas,
                        'cancelled' => $citasCanceladas,
                        'completion_rate' => round($completionRate, 2),
                        'cancellation_rate' => round($cancellationRate, 2),
                        'by_status' => $byStatus
                    ],
                    'attentions' => [
                        'total' => $totalAtenciones,
                        'average_per_day' => $days > 0 ? round($totalAtenciones / $days, 2) : 0
                    ],
                    'revenue' => [
                        'total' => number_format($totalVentas, 2, '.', ''),
                        'average_per_appointment' => $totalCitas > 0 ? number_format($totalVentas / $totalCitas, 2, '.', '') : '0.00',
                        'average_per_day' => $days > 0 ? number_format($totalVentas / $days, 2, '.', '') : '0.00'
                    ]
                ],
                'rankings' => [
                    'top_services' => $serviciosMasSolicitados->map(function ($service) {
                        return [
                            'id' => 0,
                            'name' => $service['servicio'],
                            'count' => $service['total_atenciones'],
                            'revenue' => '0.00'
                        ];
                    }),
                    'top_clients' => $personasConMasCitas->map(function ($persona) {
                        return [
                            'id' => 0,
                            'full_name' => $persona['nombre_completo'],
                            'email' => '',
                            'phone' => '',
                            'appointments_count' => $persona['total_citas'],
                            'total_spent' => '0.00'
                        ];
                    })
                ],
                'trends' => [
                    'daily_revenue' => [],
                    'daily_appointments' => []
                ]
            ]
        ]);
    }

    /**
     * Exportar reporte a CSV
     */
    public function exportarCSV(Request $request)
    {
        $tipo = $request->input('tipo');

        switch ($tipo) {
            case 'A':
                $data = $this->personasPorCita($request)->getData()->data;
                $filename = 'reporte_personas_por_cita.csv';
                break;
            case 'B':
                $data = $this->personasAtencionesServicios($request)->getData()->data;
                $filename = 'reporte_personas_atenciones_servicios.csv';
                break;
            case 'C':
                $data = $this->citasVentasPorPersona($request)->getData()->data;
                $filename = 'reporte_citas_ventas.csv';
                break;
            case 'D':
                $data = $this->citasYAtenciones($request)->getData()->data;
                $filename = 'reporte_citas_atenciones.csv';
                break;
            default:
                return response()->json(['error' => 'Tipo de reporte no válido'], 400);
        }

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
        ];

        $callback = function () use ($data) {
            $file = fopen('php://output', 'w');
            if (!empty($data)) {
                fputcsv($file, array_keys((array)$data[0]));
                foreach ($data as $row) {
                    fputcsv($file, (array)$row);
                }
            }
            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
