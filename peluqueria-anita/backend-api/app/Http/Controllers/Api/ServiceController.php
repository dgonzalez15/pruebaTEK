<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class ServiceController extends Controller
{
    /**
     * Display a listing of services.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Service::query();

        // Filtrar por servicios activos si se especifica
        if ($request->has('active') && $request->active !== null) {
            $query->where('is_active', $request->boolean('active'));
        }

        // Búsqueda por nombre o descripción
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'LIKE', "%{$search}%")
                  ->orWhere('description', 'LIKE', "%{$search}%");
            });
        }

        // Ordenar por precio o nombre
        $sortBy = $request->get('sort_by', 'name');
        $sortOrder = $request->get('sort_order', 'asc');
        
        if (in_array($sortBy, ['name', 'price', 'duration', 'created_at'])) {
            $query->orderBy($sortBy, $sortOrder);
        } else {
            $query->orderBy('name', 'asc');
        }

        // Paginación
        $perPage = $request->get('per_page', 10);
        $services = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $services->items(),
            'pagination' => [
                'current_page' => $services->currentPage(),
                'last_page' => $services->lastPage(),
                'per_page' => $services->perPage(),
                'total' => $services->total(),
            ]
        ]);
    }

    /**
     * Store a newly created service.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:services,name',
            'description' => 'required|string|max:1000',
            'price' => 'required|numeric|min:0|max:9999.99',
            'duration' => 'required|integer|min:15|max:480', // 15 min a 8 horas
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de validación incorrectos',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();
        $data['is_active'] = $data['is_active'] ?? true;

        $service = Service::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Servicio creado exitosamente',
            'data' => $service
        ], 201);
    }

    /**
     * Display the specified service.
     */
    public function show(Service $service): JsonResponse
    {
        // Cargar estadísticas del servicio
        $service->load(['appointmentDetails' => function ($query) {
            $query->whereHas('appointment', function ($q) {
                $q->where('status', 'completed');
            });
        }]);

        $stats = [
            'times_booked' => $service->appointmentDetails->count(),
            'total_revenue' => $service->appointmentDetails->sum('price'),
            'average_price' => $service->appointmentDetails->avg('price'),
        ];

        return response()->json([
            'success' => true,
            'data' => array_merge($service->toArray(), ['stats' => $stats])
        ]);
    }

    /**
     * Update the specified service.
     */
    public function update(Request $request, Service $service): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255|unique:services,name,' . $service->id,
            'description' => 'sometimes|required|string|max:1000',
            'price' => 'sometimes|required|numeric|min:0|max:9999.99',
            'duration' => 'sometimes|required|integer|min:15|max:480',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de validación incorrectos',
                'errors' => $validator->errors()
            ], 422);
        }

        $service->update($validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Servicio actualizado exitosamente',
            'data' => $service
        ]);
    }

    /**
     * Remove the specified service.
     */
    public function destroy(Service $service): JsonResponse
    {
        // Verificar si el servicio tiene citas futuras
        $futureAppointments = $service->appointmentDetails()
            ->whereHas('appointment', function ($query) {
                $query->where('appointment_date', '>=', now()->toDateString())
                      ->whereIn('status', ['pending', 'confirmed']);
            })->exists();

        if ($futureAppointments) {
            return response()->json([
                'success' => false,
                'message' => 'No se puede eliminar el servicio porque tiene citas futuras asociadas'
            ], 400);
        }

        $service->delete();

        return response()->json([
            'success' => true,
            'message' => 'Servicio eliminado exitosamente'
        ]);
    }

    /**
     * Toggle service active status.
     */
    public function toggleStatus(Service $service): JsonResponse
    {
        $service->update(['is_active' => !$service->is_active]);

        return response()->json([
            'success' => true,
            'message' => $service->is_active ? 'Servicio activado' : 'Servicio desactivado',
            'data' => $service
        ]);
    }

    /**
     * Get popular services.
     */
    public function popular(Request $request): JsonResponse
    {
        $limit = $request->get('limit', 5);
        
        $popularServices = Service::withCount(['appointmentDetails' => function ($query) {
                $query->whereHas('appointment', function ($q) {
                    $q->where('status', 'completed')
                      ->where('appointment_date', '>=', now()->subMonths(3));
                });
            }])
            ->where('is_active', true)
            ->orderBy('appointment_details_count', 'desc')
            ->limit($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $popularServices
        ]);
    }
}