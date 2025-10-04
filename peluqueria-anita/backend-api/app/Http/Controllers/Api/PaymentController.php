<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Appointment;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class PaymentController extends Controller
{
    /**
     * Display a listing of payments.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Payment::with(['appointment.client']);

        // Filtrar por estado
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filtrar por método de pago
        if ($request->has('payment_method')) {
            $query->where('payment_method', $request->payment_method);
        }

        // Filtrar por rango de fechas
        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        // Búsqueda por cliente
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->whereHas('appointment.client', function ($q) use ($search) {
                $q->where('name', 'LIKE', "%{$search}%");
            });
        }

        // Ordenamiento
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // Paginación
        $perPage = $request->get('per_page', 10);
        $payments = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $payments->items(),
            'pagination' => [
                'current_page' => $payments->currentPage(),
                'last_page' => $payments->lastPage(),
                'per_page' => $payments->perPage(),
                'total' => $payments->total(),
            ]
        ]);
    }

    /**
     * Store a newly created payment.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'appointment_id' => 'required|exists:appointments,id',
            'amount' => 'required|numeric|min:0',
            'payment_method' => 'required|in:cash,card,transfer,other',
            'status' => 'required|in:pending,completed,failed,refunded',
            'transaction_id' => 'nullable|string|max:255',
            'notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de validación incorrectos',
                'errors' => $validator->errors()
            ], 422);
        }

        // Verificar que la cita existe y está completada
        $appointment = Appointment::find($request->appointment_id);
        
        if ($appointment->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Solo se pueden registrar pagos para citas completadas'
            ], 400);
        }

        // Verificar que el monto no exceda el total de la cita
        $totalPaid = $appointment->payments()->where('status', 'completed')->sum('amount');
        $remainingAmount = $appointment->total_amount - $totalPaid;

        if ($request->amount > $remainingAmount) {
            return response()->json([
                'success' => false,
                'message' => "El monto excede lo pendiente por pagar: $remainingAmount"
            ], 400);
        }

        try {
            DB::beginTransaction();

            $payment = Payment::create($validator->validated());

            // Si el pago completa el total de la cita, marcar como totalmente pagada
            $newTotalPaid = $appointment->payments()->where('status', 'completed')->sum('amount');
            if ($newTotalPaid >= $appointment->total_amount) {
                $appointment->update(['payment_status' => 'paid']);
            } else {
                $appointment->update(['payment_status' => 'partial']);
            }

            DB::commit();

            $payment->load('appointment.client');

            return response()->json([
                'success' => true,
                'message' => 'Pago registrado exitosamente',
                'data' => $payment
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Error al registrar el pago: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified payment.
     */
    public function show(Payment $payment): JsonResponse
    {
        $payment->load(['appointment.client', 'appointment.stylist']);

        return response()->json([
            'success' => true,
            'data' => $payment
        ]);
    }

    /**
     * Update the specified payment.
     */
    public function update(Request $request, Payment $payment): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'sometimes|required|numeric|min:0',
            'payment_method' => 'sometimes|required|in:cash,card,transfer,other',
            'status' => 'sometimes|required|in:pending,completed,failed,refunded',
            'transaction_id' => 'nullable|string|max:255',
            'notes' => 'nullable|string|max:1000',
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

            $payment->update($validator->validated());

            // Recalcular el estado de pago de la cita
            $appointment = $payment->appointment;
            $totalPaid = $appointment->payments()->where('status', 'completed')->sum('amount');
            
            if ($totalPaid >= $appointment->total_amount) {
                $appointment->update(['payment_status' => 'paid']);
            } elseif ($totalPaid > 0) {
                $appointment->update(['payment_status' => 'partial']);
            } else {
                $appointment->update(['payment_status' => 'pending']);
            }

            DB::commit();

            $payment->load('appointment.client');

            return response()->json([
                'success' => true,
                'message' => 'Pago actualizado exitosamente',
                'data' => $payment
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar el pago: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified payment.
     */
    public function destroy(Payment $payment): JsonResponse
    {
        try {
            DB::beginTransaction();

            $appointment = $payment->appointment;
            $payment->delete();

            // Recalcular el estado de pago de la cita
            $totalPaid = $appointment->payments()->where('status', 'completed')->sum('amount');
            
            if ($totalPaid >= $appointment->total_amount) {
                $appointment->update(['payment_status' => 'paid']);
            } elseif ($totalPaid > 0) {
                $appointment->update(['payment_status' => 'partial']);
            } else {
                $appointment->update(['payment_status' => 'pending']);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Pago eliminado exitosamente'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Error al eliminar el pago: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get payment summary for an appointment.
     */
    public function appointmentSummary(Appointment $appointment): JsonResponse
    {
        $payments = $appointment->payments()->orderBy('created_at', 'desc')->get();
        $totalPaid = $payments->where('status', 'completed')->sum('amount');
        $pendingAmount = $appointment->total_amount - $totalPaid;

        return response()->json([
            'success' => true,
            'data' => [
                'appointment_id' => $appointment->id,
                'total_amount' => $appointment->total_amount,
                'total_paid' => $totalPaid,
                'pending_amount' => $pendingAmount,
                'payment_status' => $appointment->payment_status,
                'payments' => $payments
            ]
        ]);
    }

    /**
     * Process refund for a payment.
     */
    public function refund(Request $request, Payment $payment): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:500',
            'amount' => 'nullable|numeric|min:0|max:' . $payment->amount,
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de validación incorrectos',
                'errors' => $validator->errors()
            ], 422);
        }

        if ($payment->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Solo se pueden reembolsar pagos completados'
            ], 400);
        }

        try {
            DB::beginTransaction();

            $refundAmount = $request->amount ?? $payment->amount;
            
            // Crear registro de reembolso
            $refund = Payment::create([
                'appointment_id' => $payment->appointment_id,
                'amount' => -$refundAmount,
                'payment_method' => $payment->payment_method,
                'status' => 'completed',
                'transaction_id' => 'REFUND-' . $payment->id . '-' . time(),
                'notes' => 'Reembolso: ' . $request->reason,
            ]);

            // Actualizar el pago original
            $payment->update([
                'status' => 'refunded',
                'notes' => ($payment->notes ?? '') . ' | Reembolsado: ' . $request->reason
            ]);

            // Recalcular estado de pago de la cita
            $appointment = $payment->appointment;
            $totalPaid = $appointment->payments()->where('status', 'completed')->sum('amount');
            
            if ($totalPaid >= $appointment->total_amount) {
                $appointment->update(['payment_status' => 'paid']);
            } elseif ($totalPaid > 0) {
                $appointment->update(['payment_status' => 'partial']);
            } else {
                $appointment->update(['payment_status' => 'pending']);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Reembolso procesado exitosamente',
                'data' => [
                    'original_payment' => $payment,
                    'refund' => $refund
                ]
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Error al procesar el reembolso: ' . $e->getMessage()
            ], 500);
        }
    }
}