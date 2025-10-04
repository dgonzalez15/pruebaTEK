<?php

namespace App\Http\Controllers;

use App\Models\Attention;
use App\Models\Client;
use App\Models\User;
use App\Models\Service;
use App\Models\Appointment;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class AttentionController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Attention::with(['client', 'user', 'service', 'appointment']);

        // Filtros
        if ($request->has('date')) {
            $query->where('attention_date', $request->date);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('stylist_id')) {
            $query->where('user_id', $request->stylist_id);
        }

        if ($request->has('client_id')) {
            $query->where('client_id', $request->client_id);
        }

        // Búsqueda por cliente
        if ($request->has('search')) {
            $query->whereHas('client', function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('email', 'like', '%' . $request->search . '%');
            });
        }

        // Ordenamiento
        $sortBy = $request->get('sort_by', 'attention_date');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // Paginación
        $perPage = $request->get('per_page', 15);
        $attentions = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $attentions,
            'message' => 'Atenciones obtenidas exitosamente'
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'appointment_id' => 'required|exists:appointments,id',
            'client_id' => 'required|exists:clients,id',
            'user_id' => 'required|exists:users,id',
            'service_id' => 'required|exists:services,id',
            'attention_date' => 'required|date',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'status' => ['required', Rule::in(['started', 'in_progress', 'completed', 'cancelled'])],
            'service_price' => 'required|numeric|min:0',
            'observations' => 'nullable|string',
            'products_used' => 'nullable|string',
            'tip_amount' => 'nullable|numeric|min:0',
            'client_satisfaction' => ['nullable', Rule::in(['very_unsatisfied', 'unsatisfied', 'neutral', 'satisfied', 'very_satisfied'])],
            'notes' => 'nullable|string'
        ]);

        $attention = Attention::create($request->all());
        $attention->load(['client', 'user', 'service', 'appointment']);

        return response()->json([
            'success' => true,
            'data' => $attention,
            'message' => 'Atención creada exitosamente'
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id): JsonResponse
    {
        $attention = Attention::with(['client', 'user', 'service', 'appointment'])->find($id);

        if (!$attention) {
            return response()->json([
                'success' => false,
                'message' => 'Atención no encontrada'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $attention,
            'message' => 'Atención obtenida exitosamente'
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $attention = Attention::find($id);

        if (!$attention) {
            return response()->json([
                'success' => false,
                'message' => 'Atención no encontrada'
            ], 404);
        }

        $request->validate([
            'appointment_id' => 'sometimes|exists:appointments,id',
            'client_id' => 'sometimes|exists:clients,id',
            'user_id' => 'sometimes|exists:users,id',
            'service_id' => 'sometimes|exists:services,id',
            'attention_date' => 'sometimes|date',
            'start_time' => 'sometimes|date_format:H:i',
            'end_time' => 'sometimes|date_format:H:i|after:start_time',
            'status' => ['sometimes', Rule::in(['started', 'in_progress', 'completed', 'cancelled'])],
            'service_price' => 'sometimes|numeric|min:0',
            'observations' => 'nullable|string',
            'products_used' => 'nullable|string',
            'tip_amount' => 'nullable|numeric|min:0',
            'client_satisfaction' => ['nullable', Rule::in(['very_unsatisfied', 'unsatisfied', 'neutral', 'satisfied', 'very_satisfied'])],
            'notes' => 'nullable|string'
        ]);

        $attention->update($request->all());
        $attention->load(['client', 'user', 'service', 'appointment']);

        return response()->json([
            'success' => true,
            'data' => $attention,
            'message' => 'Atención actualizada exitosamente'
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id): JsonResponse
    {
        $attention = Attention::find($id);

        if (!$attention) {
            return response()->json([
                'success' => false,
                'message' => 'Atención no encontrada'
            ], 404);
        }

        $attention->delete();

        return response()->json([
            'success' => true,
            'message' => 'Atención eliminada exitosamente'
        ]);
    }

    /**
     * Cambiar estado de una atención
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $attention = Attention::find($id);

        if (!$attention) {
            return response()->json([
                'success' => false,
                'message' => 'Atención no encontrada'
            ], 404);
        }

        $request->validate([
            'status' => ['required', Rule::in(['started', 'in_progress', 'completed', 'cancelled'])],
            'notes' => 'nullable|string'
        ]);

        $attention->update([
            'status' => $request->status,
            'notes' => $request->notes ?? $attention->notes
        ]);

        $attention->load(['client', 'user', 'service', 'appointment']);

        return response()->json([
            'success' => true,
            'data' => $attention,
            'message' => 'Estado de atención actualizado exitosamente'
        ]);
    }

    /**
     * Obtener estadísticas de atenciones
     */
    public function stats(): JsonResponse
    {
        // Estadísticas generales
        $totalAttentions = Attention::count();
        $completedAttentions = Attention::where('status', 'completed')->count();
        $inProgressAttentions = Attention::where('status', 'in_progress')->count();
        $startedAttentions = Attention::where('status', 'started')->count();
        $cancelledAttentions = Attention::where('status', 'cancelled')->count();

        // Estadísticas del mes actual
        $thisMonth = now()->format('Y-m');
        $attentionsThisMonth = Attention::whereRaw("DATE_FORMAT(attention_date, '%Y-%m') = ?", [$thisMonth])->count();
        $completedThisMonth = Attention::where('status', 'completed')
            ->whereRaw("DATE_FORMAT(attention_date, '%Y-%m') = ?", [$thisMonth])
            ->count();

        // Ingresos del mes (solo atenciones completadas)
        $revenueThisMonth = Attention::where('status', 'completed')
            ->whereRaw("DATE_FORMAT(attention_date, '%Y-%m') = ?", [$thisMonth])
            ->sum('service_price');

        // Promedio de satisfacción del cliente
        $averageSatisfaction = Attention::where('status', 'completed')
            ->whereNotNull('client_satisfaction')
            ->selectRaw('
                CASE client_satisfaction
                    WHEN "very_unsatisfied" THEN 1
                    WHEN "unsatisfied" THEN 2
                    WHEN "neutral" THEN 3
                    WHEN "satisfied" THEN 4
                    WHEN "very_satisfied" THEN 5
                END as satisfaction_score
            ')
            ->get()
            ->avg('satisfaction_score');

        // Top estilistas por atenciones completadas
        $topStylists = Attention::with('user')
            ->where('status', 'completed')
            ->selectRaw('user_id, count(*) as total_attentions, sum(service_price) as total_revenue')
            ->groupBy('user_id')
            ->orderByDesc('total_attentions')
            ->limit(5)
            ->get();

        // Servicios más populares
        $popularServices = Attention::with('service')
            ->where('status', 'completed')
            ->selectRaw('service_id, count(*) as times_performed')
            ->groupBy('service_id')
            ->orderByDesc('times_performed')
            ->limit(5)
            ->get();

        // Atenciones por mes (últimos 6 meses)
        $attentionsByMonth = Attention::selectRaw('MONTH(attention_date) as month, YEAR(attention_date) as year, count(*) as count')
            ->where('attention_date', '>=', now()->subMonths(6))
            ->groupBy('year', 'month')
            ->orderBy('year', 'desc')
            ->orderBy('month', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'total_attentions' => $totalAttentions,
                'completed_attentions' => $completedAttentions,
                'in_progress_attentions' => $inProgressAttentions,
                'started_attentions' => $startedAttentions,
                'cancelled_attentions' => $cancelledAttentions,
                'attentions_this_month' => $attentionsThisMonth,
                'completed_this_month' => $completedThisMonth,
                'revenue_this_month' => round($revenueThisMonth, 2),
                'average_satisfaction' => round($averageSatisfaction, 2),
                'top_stylists' => $topStylists,
                'popular_services' => $popularServices,
                'attentions_by_month' => $attentionsByMonth
            ],
            'message' => 'Estadísticas de atenciones obtenidas exitosamente'
        ]);
    }
}