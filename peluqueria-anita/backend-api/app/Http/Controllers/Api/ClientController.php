<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Client;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Validator;

class ClientController extends Controller
{
    /**
     * Display a listing of clients.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Client::query();

        // Búsqueda por nombre, email o teléfono
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'LIKE', "%{$search}%")
                  ->orWhere('email', 'LIKE', "%{$search}%")
                  ->orWhere('phone', 'LIKE', "%{$search}%");
            });
        }

        // Paginación
        $perPage = $request->get('per_page', 10);
        $clients = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $clients->items(),
            'pagination' => [
                'current_page' => $clients->currentPage(),
                'last_page' => $clients->lastPage(),
                'per_page' => $clients->perPage(),
                'total' => $clients->total(),
            ]
        ]);
    }

    /**
     * Store a newly created client.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:clients,email',
            'phone' => 'required|string|max:20',
            'address' => 'nullable|string|max:500',
            'birth_date' => 'nullable|date',
            'preferences' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de validación incorrectos',
                'errors' => $validator->errors()
            ], 422);
        }

        $client = Client::create($validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Cliente creado exitosamente',
            'data' => $client
        ], 201);
    }

    /**
     * Display the specified client.
     */
    public function show(Client $client): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $client
        ]);
    }

    /**
     * Update the specified client.
     */
    public function update(Request $request, Client $client): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:clients,email,' . $client->id,
            'phone' => 'sometimes|required|string|max:20',
            'address' => 'nullable|string|max:500',
            'birth_date' => 'nullable|date',
            'preferences' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de validación incorrectos',
                'errors' => $validator->errors()
            ], 422);
        }

        $client->update($validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Cliente actualizado exitosamente',
            'data' => $client
        ]);
    }

    /**
     * Remove the specified client.
     */
    public function destroy(Client $client): JsonResponse
    {
        // Verificar si el cliente tiene citas
        if ($client->appointments()->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'No se puede eliminar el cliente porque tiene citas asociadas'
            ], 400);
        }

        $client->delete();

        return response()->json([
            'success' => true,
            'message' => 'Cliente eliminado exitosamente'
        ]);
    }

    /**
     * Get client statistics.
     */
    public function stats(Client $client): JsonResponse
    {
        $stats = [
            'total_appointments' => $client->appointments()->count(),
            'completed_appointments' => $client->appointments()->where('status', 'completed')->count(),
            'total_spent' => $client->appointments()->where('status', 'completed')->sum('total_amount'),
            'last_appointment' => $client->appointments()->latest()->first(),
            'favorite_services' => $client->appointments()
                ->with('appointmentDetails.service')
                ->get()
                ->flatMap(function ($appointment) {
                    return $appointment->appointmentDetails->pluck('service');
                })
                ->countBy('name')
                ->sortDesc()
                ->take(3)
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }
}