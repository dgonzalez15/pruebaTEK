<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClientController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\AttentionController;
use App\Http\Controllers\ClientController as MainClientController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Rutas públicas de autenticación
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
});

// TEMPORAL: Rutas de clientes sin autenticación para pruebas
// IMPORTANTE: Las rutas específicas deben ir ANTES de apiResource
Route::prefix('clients')->group(function () {
    Route::get('stats', [MainClientController::class, 'stats']);
    Route::patch('{client}/toggle-status', [MainClientController::class, 'toggleStatus']);
    Route::get('{client}/appointments', [MainClientController::class, 'appointments']);
});
Route::apiResource('clients', MainClientController::class);

// Rutas protegidas por autenticación
Route::middleware('auth:sanctum')->group(function () {
    // Autenticación
    Route::prefix('auth')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('user', [AuthController::class, 'user']);
        Route::put('profile', [AuthController::class, 'updateProfile']);
    });
    
    // Servicios
    Route::prefix('services')->group(function () {
        Route::get('popular', [ServiceController::class, 'popular']);
        Route::patch('{service}/toggle-status', [ServiceController::class, 'toggleStatus']);
    });
    Route::apiResource('services', ServiceController::class);
    
    // Citas - CRUD Completo
    // IMPORTANTE: Las rutas específicas deben ir ANTES de apiResource
    Route::prefix('appointments')->group(function () {
        Route::get('today', [AppointmentController::class, 'todayAppointments']);
        Route::get('available-slots', [AppointmentController::class, 'availableSlots']);
        Route::get('search', [AppointmentController::class, 'searchByClient']);
        Route::get('stats', [AppointmentController::class, 'stats']);
        Route::patch('{appointment}/status', [AppointmentController::class, 'updateStatus']);
        Route::patch('{appointment}/confirm', [AppointmentController::class, 'confirmAppointment']);
        Route::patch('{appointment}/complete', [AppointmentController::class, 'completeAppointment']);
        Route::patch('{appointment}/cancel', [AppointmentController::class, 'cancelAppointment']);
        Route::patch('{appointment}/reschedule', [AppointmentController::class, 'reschedule']);
    });
    Route::apiResource('appointments', AppointmentController::class);
    
    // Atenciones - CRUD Completo
    // IMPORTANTE: Las rutas específicas deben ir ANTES de apiResource
    Route::prefix('attentions')->group(function () {
        Route::get('stats', [AttentionController::class, 'stats']);
        Route::patch('{attention}/status', [AttentionController::class, 'updateStatus']);
    });
    Route::apiResource('attentions', AttentionController::class);
    
    // Pagos
    Route::apiResource('payments', PaymentController::class);
    Route::prefix('payments')->group(function () {
        Route::get('appointment/{appointment}/summary', [PaymentController::class, 'appointmentSummary']);
        Route::post('{payment}/refund', [PaymentController::class, 'refund']);
    });
    
    // Dashboard y estadísticas
    Route::prefix('dashboard')->group(function () {
        Route::get('stats', [DashboardController::class, 'stats']);
        Route::get('monthly-overview', [DashboardController::class, 'monthlyOverview']);
        Route::get('quick-stats', [DashboardController::class, 'quickStats']);
    });

    // Usuarios/Estilistas (para el dropdown de estilistas)
    Route::get('stylists', function () {
        return response()->json([
            'success' => true,
            'data' => \App\Models\User::where('role', 'stylist')->get(['id', 'name', 'email'])
        ]);
    });
});

// Ruta de estado de la API
Route::get('health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API Peluquería Anita funcionando correctamente',
        'timestamp' => now()->toISOString(),
        'version' => '2.0.0',
        'features' => [
            'clients_crud' => 'enabled',
            'appointments_crud' => 'enabled', 
            'attentions_crud' => 'enabled',
            'advanced_stats' => 'enabled'
        ]
    ]);
});