<?php

use App\Http\Controllers\Api\AuthController;
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

// Rutas protegidas por autenticación
Route::middleware('auth:sanctum')->group(function () {
    // Autenticación
    Route::prefix('auth')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('user', [AuthController::class, 'user']);
        Route::put('profile', [AuthController::class, 'updateProfile']);
    });

    // Clientes
    Route::apiResource('clients', App\Http\Controllers\Api\ClientController::class);
    
    // Servicios
    Route::apiResource('services', App\Http\Controllers\Api\ServiceController::class);
    
    // Citas
    Route::apiResource('appointments', App\Http\Controllers\Api\AppointmentController::class);
    Route::prefix('appointments')->group(function () {
        Route::get('today', [App\Http\Controllers\Api\AppointmentController::class, 'today']);
        Route::get('by-stylist/{stylistId}', [App\Http\Controllers\Api\AppointmentController::class, 'byStylist']);
        Route::patch('{appointment}/status', [App\Http\Controllers\Api\AppointmentController::class, 'updateStatus']);
    });
    
    // Pagos
    Route::apiResource('payments', App\Http\Controllers\Api\PaymentController::class);
    
    // Dashboard y estadísticas
    Route::get('dashboard/stats', [App\Http\Controllers\Api\DashboardController::class, 'stats']);
    Route::get('dashboard/revenue', [App\Http\Controllers\Api\DashboardController::class, 'revenue']);
    Route::get('dashboard/appointments-calendar', [App\Http\Controllers\Api\DashboardController::class, 'appointmentsCalendar']);
});

// Ruta de estado de la API
Route::get('health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API Peluquería Anita funcionando correctamente',
        'timestamp' => now()->toISOString()
    ]);
});