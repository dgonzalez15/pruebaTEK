<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\AppointmentDetail;
use App\Models\Client;
use App\Models\Service;
use App\Models\User;
use App\Models\Attention;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class AppointmentController extends Controller
{
    /**
     * Display a listing of appointments.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Appointment::with(['client', 'stylist', 'appointmentDetails.service']);

        // Filtrar por fecha
        if ($request->has('date')) {
            $query->whereDate('appointment_date', $request->date);
        }

        // Filtrar por estilista
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        // Filtrar por cliente
        if ($request->has('client_id')) {
            $query->where('client_id', $request->client_id);
        }

        // Filtrar por estado
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filtrar por rango de fechas
        if ($request->has('date_from')) {
            $query->whereDate('appointment_date', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('appointment_date', '<=', $request->date_to);
        }

        // Búsqueda por nombre de cliente
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->whereHas('client', function ($q) use ($search) {
                $q->where('name', 'LIKE', "%{$search}%")
                  ->orWhere('email', 'LIKE', "%{$search}%");
            });
        }

        // Ordenamiento
        $sortBy = $request->get('sort_by', 'appointment_date');
        $sortOrder = $request->get('sort_order', 'asc');
        
        if ($sortBy === 'appointment_date') {
            $query->orderBy('appointment_date', $sortOrder)
                  ->orderBy('start_time', $sortOrder);
        } else {
            $query->orderBy($sortBy, $sortOrder);
        }

        // Paginación
        $perPage = $request->get('per_page', 10);
        $appointments = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $appointments->items(),
            'pagination' => [
                'current_page' => $appointments->currentPage(),
                'last_page' => $appointments->lastPage(),
                'per_page' => $appointments->perPage(),
                'total' => $appointments->total(),
            ]
        ]);
    }

    /**
     * Store a newly created appointment.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'client_id' => 'required|exists:clients,id',
            'user_id' => 'required|exists:users,id',
            'appointment_date' => 'required|date|after_or_equal:today',
            'start_time' => 'required|date_format:H:i',
            'notes' => 'nullable|string|max:1000',
            'services' => 'required|array|min:1',
            'services.*.service_id' => 'required|exists:services,id',
            'services.*.price' => 'required|numeric|min:0',
            'services.*.quantity' => 'sometimes|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de validación incorrectos',
                'errors' => $validator->errors()
            ], 422);
        }

        // Verificar que el estilista esté disponible
        $existingAppointment = Appointment::where('user_id', $request->user_id)
            ->where('appointment_date', $request->appointment_date)
            ->where('start_time', $request->start_time)
            ->whereIn('status', ['pending', 'confirmed', 'in_progress'])
            ->exists();

        if ($existingAppointment) {
            return response()->json([
                'success' => false,
                'message' => 'El estilista no está disponible en esa fecha y hora'
            ], 400);
        }

        try {
            DB::beginTransaction();

            // Calcular el total y duración
            $totalAmount = collect($request->services)->sum('price');
            
            // Asegurar que el total es un número
            $totalAmount = (float) $totalAmount;
            
            // Obtener la duración total de los servicios
            $serviceIds = collect($request->services)->pluck('service_id');
            $totalDuration = \App\Models\Service::whereIn('id', $serviceIds)->sum('duration');
            
            // Asegurar que la duración es un número entero
            $totalDuration = (int) $totalDuration;
            
            // Calcular end_time
            $startTime = \Carbon\Carbon::createFromFormat('H:i', $request->start_time);
            $endTime = $startTime->copy()->addMinutes($totalDuration);

            // Crear la cita
            $appointment = Appointment::create([
                'client_id' => $request->client_id,
                'user_id' => $request->user_id,
                'appointment_date' => $request->appointment_date,
                'start_time' => $request->start_time,
                'end_time' => $endTime->format('H:i:s'),
                'status' => 'pending',
                'notes' => $request->notes,
                'total_amount' => $totalAmount,
            ]);

            // Crear los detalles de la cita
            foreach ($request->services as $serviceData) {
                $quantity = $serviceData['quantity'] ?? 1;
                $unitPrice = $serviceData['price'];
                $subtotal = $quantity * $unitPrice;
                
                AppointmentDetail::create([
                    'appointment_id' => $appointment->id,
                    'service_id' => $serviceData['service_id'],
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'subtotal' => $subtotal,
                ]);
            }

            DB::commit();

            // Cargar relaciones para la respuesta
            $appointment->load(['client', 'stylist', 'appointmentDetails.service']);

            return response()->json([
                'success' => true,
                'message' => 'Cita creada exitosamente',
                'data' => $appointment
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Error al crear la cita: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified appointment.
     */
    public function show(Appointment $appointment): JsonResponse
    {
        $appointment->load(['client', 'stylist', 'appointmentDetails.service', 'payments']);

        return response()->json([
            'success' => true,
            'data' => $appointment
        ]);
    }

    /**
     * Update the specified appointment.
     */
    public function update(Request $request, Appointment $appointment): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'client_id' => 'sometimes|required|exists:clients,id',
            'user_id' => 'sometimes|required|exists:users,id',
            'appointment_date' => 'sometimes|required|date',
            'start_time' => 'sometimes|required|date_format:H:i',
            'status' => 'sometimes|required|in:pending,confirmed,in_progress,completed,cancelled',
            'notes' => 'nullable|string|max:1000',
            'services' => 'sometimes|array|min:1',
            'services.*.service_id' => 'required_with:services|exists:services,id',
            'services.*.price' => 'required_with:services|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de validación incorrectos',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            DB::beginTransaction();

            $data = $validator->validated();

            // Si se están actualizando los servicios, recalcular el total
            if (isset($data['services'])) {
                $totalAmount = collect($data['services'])->sum('price');
                $data['total_amount'] = $totalAmount;

                // Eliminar detalles existentes y crear nuevos
                $appointment->appointmentDetails()->delete();
                
                foreach ($data['services'] as $serviceData) {
                    AppointmentDetail::create([
                        'appointment_id' => $appointment->id,
                        'service_id' => $serviceData['service_id'],
                        'price' => $serviceData['price'],
                    ]);
                }

                unset($data['services']);
            }

            $appointment->update($data);

            DB::commit();

            $appointment->load(['client', 'stylist', 'appointmentDetails.service']);

            return response()->json([
                'success' => true,
                'message' => 'Cita actualizada exitosamente',
                'data' => $appointment
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar la cita: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified appointment.
     */
    public function destroy(Appointment $appointment): JsonResponse
    {
        // Solo permitir cancelar/eliminar citas que no estén completadas
        if ($appointment->status === 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'No se puede eliminar una cita completada'
            ], 400);
        }

        try {
            DB::beginTransaction();

            // Eliminar detalles y pagos asociados
            $appointment->appointmentDetails()->delete();
            $appointment->payments()->delete();
            
            // Eliminar la cita
            $appointment->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Cita eliminada exitosamente'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Error al eliminar la cita: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get today's appointments.
     */
    public function today(): JsonResponse
    {
        $appointments = Appointment::with(['client', 'stylist', 'appointmentDetails.service'])
            ->whereDate('appointment_date', today())
            ->orderBy('start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $appointments
        ]);
    }

    /**
     * Update appointment status.
     */
    public function updateStatus(Request $request, Appointment $appointment): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,confirmed,in_progress,completed,cancelled'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Estado inválido',
                'errors' => $validator->errors()
            ], 422);
        }

        $appointment->update(['status' => $request->status]);

        return response()->json([
            'success' => true,
            'message' => 'Estado de la cita actualizado',
            'data' => $appointment
        ]);
    }

    /**
     * Get available time slots for a stylist on a specific date.
     */
    public function availableSlots(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'date' => 'required|date|after_or_equal:today'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $stylistId = $request->user_id;
        $date = $request->date;

        // Horarios de trabajo (esto podría venir de una configuración)
        $workingHours = [
            'start' => '09:00',
            'end' => '18:00',
            'slot_duration' => 30 // minutos
        ];

        // Obtener citas ocupadas
        $bookedSlots = Appointment::where('user_id', $stylistId)
            ->whereDate('appointment_date', $date)
            ->whereIn('status', ['pending', 'confirmed', 'in_progress'])
            ->pluck('start_time')
            ->toArray();

        // Generar slots disponibles
        $availableSlots = [];
        $current = Carbon::createFromFormat('H:i', $workingHours['start']);
        $end = Carbon::createFromFormat('H:i', $workingHours['end']);

        while ($current < $end) {
            $timeSlot = $current->format('H:i');
            
            if (!in_array($timeSlot, $bookedSlots)) {
                $availableSlots[] = $timeSlot;
            }
            
            $current->addMinutes($workingHours['slot_duration']);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'date' => $date,
                'user_id' => $stylistId,
                'available_slots' => $availableSlots
            ]
        ]);
    }

    /**
     * Confirmar una cita
     */
    public function confirmAppointment(string $id): JsonResponse
    {
        $appointment = Appointment::find($id);

        if (!$appointment) {
            return response()->json([
                'success' => false,
                'message' => 'Cita no encontrada'
            ], 404);
        }

        $appointment->update(['status' => 'confirmed']);

        return response()->json([
            'success' => true,
            'data' => $appointment->load(['client', 'stylist', 'appointmentDetails.service']),
            'message' => 'Cita confirmada exitosamente'
        ]);
    }

    /**
     * Marcar cita como completada
     */
    public function completeAppointment(string $id): JsonResponse
    {
        $appointment = Appointment::find($id);

        if (!$appointment) {
            return response()->json([
                'success' => false,
                'message' => 'Cita no encontrada'
            ], 404);
        }

        $appointment->update(['status' => 'completed']);

        return response()->json([
            'success' => true,
            'data' => $appointment->load(['client', 'stylist', 'appointmentDetails.service']),
            'message' => 'Cita marcada como completada'
        ]);
    }

    /**
     * Cancelar una cita
     */
    public function cancelAppointment(Request $request, string $id): JsonResponse
    {
        $appointment = Appointment::find($id);

        if (!$appointment) {
            return response()->json([
                'success' => false,
                'message' => 'Cita no encontrada'
            ], 404);
        }

        $request->validate([
            'notes' => 'nullable|string|max:500'
        ]);

        $appointment->update([
            'status' => 'cancelled',
            'notes' => $request->notes ?? $appointment->notes
        ]);

        return response()->json([
            'success' => true,
            'data' => $appointment->load(['client', 'stylist', 'appointmentDetails.service']),
            'message' => 'Cita cancelada exitosamente'
        ]);
    }

    /**
     * Obtener citas del día para un estilista
     */
    public function todayAppointments(Request $request): JsonResponse
    {
        $userId = $request->get('user_id', auth()->id());
        $date = $request->get('date', now()->toDateString());

        $appointments = Appointment::with(['client', 'appointmentDetails.service'])
            ->where('user_id', $userId)
            ->whereDate('appointment_date', $date)
            ->orderBy('start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $appointments,
            'message' => 'Citas del día obtenidas exitosamente'
        ]);
    }

    /**
     * Buscar citas por cliente
     */
    public function searchByClient(Request $request): JsonResponse
    {
        $search = $request->get('search');
        
        if (!$search) {
            return response()->json([
                'success' => false,
                'message' => 'Término de búsqueda requerido'
            ], 400);
        }

        $appointments = Appointment::with(['client', 'stylist', 'appointmentDetails.service'])
            ->whereHas('client', function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%')
                      ->orWhere('email', 'like', '%' . $search . '%')
                      ->orWhere('phone', 'like', '%' . $search . '%');
            })
            ->orderBy('appointment_date', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $appointments,
            'message' => 'Citas encontradas exitosamente'
        ]);
    }

    /**
     * Reprogramar una cita
     */
    public function reschedule(Request $request, string $id): JsonResponse
    {
        $appointment = Appointment::find($id);

        if (!$appointment) {
            return response()->json([
                'success' => false,
                'message' => 'Cita no encontrada'
            ], 404);
        }

        $request->validate([
            'appointment_date' => 'required|date|after_or_equal:today',
            'start_time' => 'required|date_format:H:i',
            'user_id' => 'sometimes|exists:users,id',
            'notes' => 'nullable|string'
        ]);

        // Calcular end_time basado en la duración de los servicios
        $totalDuration = $appointment->appointmentDetails->sum(function ($detail) {
            return $detail->service->duration_minutes;
        });

        $startTime = Carbon::parse($request->start_time);
        $endTime = $startTime->copy()->addMinutes($totalDuration);

        $appointment->update([
            'appointment_date' => $request->appointment_date,
            'start_time' => $request->start_time,
            'end_time' => $endTime->format('H:i:s'),
            'user_id' => $request->user_id ?? $appointment->user_id,
            'notes' => $request->notes ?? $appointment->notes
        ]);

        return response()->json([
            'success' => true,
            'data' => $appointment->load(['client', 'stylist', 'appointmentDetails.service']),
            'message' => 'Cita reprogramada exitosamente'
        ]);
    }

    /**
     * Estadísticas de citas
     */
    public function stats(Request $request): JsonResponse
    {
        $dateFrom = $request->get('date_from', now()->startOfMonth()->toDateString());
        $dateTo = $request->get('date_to', now()->toDateString());
        $userId = $request->get('user_id');

        $query = Appointment::whereBetween('appointment_date', [$dateFrom, $dateTo]);
        
        if ($userId) {
            $query->where('user_id', $userId);
        }

        $totalAppointments = (clone $query)->count();
        $completedAppointments = (clone $query)->where('status', 'completed')->count();
        $cancelledAppointments = (clone $query)->where('status', 'cancelled')->count();
        $pendingAppointments = (clone $query)->where('status', 'pending')->count();
        $totalRevenue = (clone $query)->where('status', 'completed')->sum('total_amount');

        $appointmentsByDay = (clone $query)
            ->selectRaw('DATE(appointment_date) as date, COUNT(*) as count')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $appointmentsByStatus = (clone $query)
            ->selectRaw('status, COUNT(*) as count')
            ->groupBy('status')
            ->get();

        $topServices = AppointmentDetail::whereHas('appointment', function ($q) use ($dateFrom, $dateTo, $userId) {
                $q->whereBetween('appointment_date', [$dateFrom, $dateTo])
                  ->where('status', 'completed');
                if ($userId) {
                    $q->where('user_id', $userId);
                }
            })
            ->with('service')
            ->selectRaw('service_id, COUNT(*) as count, SUM(price) as revenue')
            ->groupBy('service_id')
            ->orderByDesc('count')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'total_appointments' => $totalAppointments,
                'completed_appointments' => $completedAppointments,
                'cancelled_appointments' => $cancelledAppointments,
                'pending_appointments' => $pendingAppointments,
                'total_revenue' => $totalRevenue,
                'completion_rate' => $totalAppointments > 0 ? round(($completedAppointments / $totalAppointments) * 100, 2) : 0,
                'appointments_by_day' => $appointmentsByDay,
                'appointments_by_status' => $appointmentsByStatus,
                'top_services' => $topServices
            ],
            'message' => 'Estadísticas de citas obtenidas exitosamente'
        ]);
    }
}