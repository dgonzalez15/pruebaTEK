<?php

namespace App\Http\Controllers;

use App\Models\Client;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class ClientController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Client::query();

        // Filtros
        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        if ($request->has('gender')) {
            $query->where('gender', $request->gender);
        }

        // Búsqueda
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', '%' . $search . '%')
                  ->orWhere('email', 'like', '%' . $search . '%')
                  ->orWhere('phone', 'like', '%' . $search . '%');
            });
        }

        // Ordenamiento
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // Paginación
        $perPage = $request->get('per_page', 15);
        $clients = $query->paginate($perPage);

        // Agregar estadísticas de cada cliente
        $clients->through(function ($client) {
            $client->appointments_count = $client->appointments()->count();
            $client->last_appointment = $client->appointments()
                ->orderBy('appointment_date', 'desc')
                ->first()?->appointment_date;
            $client->total_spent = $client->appointments()
                ->where('status', 'completed')
                ->sum('total_amount');
            return $client;
        });

        return response()->json([
            'success' => true,
            'data' => $clients,
            'message' => 'Clientes obtenidos exitosamente'
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:100',
            'email' => 'nullable|email|unique:clients,email',
            'phone' => 'required|string|max:20',
            'address' => 'nullable|string',
            'birth_date' => 'nullable|date|before:today',
            'gender' => ['nullable', Rule::in(['male', 'female', 'other'])],
            'notes' => 'nullable|string',
            'is_active' => 'boolean'
        ]);

        $client = Client::create($request->all());

        return response()->json([
            'success' => true,
            'data' => $client,
            'message' => 'Cliente creado exitosamente'
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id): JsonResponse
    {
        $client = Client::find($id);

        if (!$client) {
            return response()->json([
                'success' => false,
                'message' => 'Cliente no encontrado'
            ], 404);
        }

        // Agregar estadísticas del cliente
        $client->appointments_count = $client->appointments()->count();
        $client->completed_appointments = $client->appointments()->where('status', 'completed')->count();
        $client->total_spent = $client->appointments()->where('status', 'completed')->sum('total_amount');
        $client->last_appointment = $client->appointments()
            ->orderBy('appointment_date', 'desc')
            ->first();
        $client->favorite_services = $client->appointments()
            ->with('appointmentDetails.service')
            ->where('status', 'completed')
            ->get()
            ->flatMap(function ($appointment) {
                return $appointment->appointmentDetails->pluck('service');
            })
            ->groupBy('id')
            ->map(function ($services) {
                return [
                    'service' => $services->first(),
                    'count' => $services->count()
                ];
            })
            ->sortByDesc('count')
            ->take(3)
            ->values();

        return response()->json([
            'success' => true,
            'data' => $client,
            'message' => 'Cliente obtenido exitosamente'
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $client = Client::find($id);

        if (!$client) {
            return response()->json([
                'success' => false,
                'message' => 'Cliente no encontrado'
            ], 404);
        }

        $request->validate([
            'name' => 'sometimes|string|max:100',
            'email' => [
                'nullable',
                'email',
                Rule::unique('clients', 'email')->ignore($client->id)
            ],
            'phone' => 'sometimes|string|max:20',
            'address' => 'nullable|string',
            'birth_date' => 'nullable|date|before:today',
            'gender' => ['nullable', Rule::in(['male', 'female', 'other'])],
            'notes' => 'nullable|string',
            'is_active' => 'boolean'
        ]);

        $client->update($request->all());

        return response()->json([
            'success' => true,
            'data' => $client,
            'message' => 'Cliente actualizado exitosamente'
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id): JsonResponse
    {
        $client = Client::find($id);

        if (!$client) {
            return response()->json([
                'success' => false,
                'message' => 'Cliente no encontrado'
            ], 404);
        }

        // Verificar si tiene citas futuras
        $futureAppointments = $client->appointments()
            ->where('appointment_date', '>=', now()->toDateString())
            ->where('status', '!=', 'cancelled')
            ->count();

        if ($futureAppointments > 0) {
            return response()->json([
                'success' => false,
                'message' => 'No se puede eliminar el cliente porque tiene citas programadas'
            ], 400);
        }

        $client->delete();

        return response()->json([
            'success' => true,
            'message' => 'Cliente eliminado exitosamente'
        ]);
    }

    /**
     * Desactivar/activar cliente
     */
    public function toggleStatus(string $id): JsonResponse
    {
        $client = Client::find($id);

        if (!$client) {
            return response()->json([
                'success' => false,
                'message' => 'Cliente no encontrado'
            ], 404);
        }

        $client->update(['is_active' => !$client->is_active]);

        return response()->json([
            'success' => true,
            'data' => $client,
            'message' => $client->is_active ? 'Cliente activado exitosamente' : 'Cliente desactivado exitosamente'
        ]);
    }

    /**
     * Obtener historial de citas del cliente
     */
    public function appointments(string $id): JsonResponse
    {
        $client = Client::find($id);

        if (!$client) {
            return response()->json([
                'success' => false,
                'message' => 'Cliente no encontrado'
            ], 404);
        }

        $appointments = $client->appointments()
            ->with(['user', 'appointmentDetails.service'])
            ->orderBy('appointment_date', 'desc')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $appointments,
            'message' => 'Historial de citas obtenido exitosamente'
        ]);
    }

    /**
     * Estadísticas generales de clientes
     */
    public function stats(): JsonResponse
    {
        $totalClients = Client::count();
        $activeClients = Client::where('is_active', true)->count();
        $clientsThisMonth = Client::whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->count();
        
        $topClients = Client::withSum(['appointments as total_spent' => function ($query) {
                $query->where('status', 'completed');
            }], 'total_amount')
            ->orderByDesc('total_spent')
            ->limit(5)
            ->get();

        $clientsByGender = Client::selectRaw('gender, COUNT(*) as count')
            ->groupBy('gender')
            ->get();

        $clientsByMonth = Client::selectRaw('MONTH(created_at) as month, COUNT(*) as count')
            ->whereYear('created_at', now()->year)
            ->groupBy('month')
            ->orderBy('month')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'total_clients' => $totalClients,
                'active_clients' => $activeClients,
                'inactive_clients' => $totalClients - $activeClients,
                'new_clients_this_month' => $clientsThisMonth,
                'top_clients' => $topClients,
                'clients_by_gender' => $clientsByGender,
                'clients_by_month' => $clientsByMonth
            ],
            'message' => 'Estadísticas de clientes obtenidas exitosamente'
        ]);
    }
}