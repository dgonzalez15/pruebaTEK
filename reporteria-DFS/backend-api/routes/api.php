<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ReportController;

// Rutas de login (sin autenticación) - alias para frontend
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Health check
Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});

// Rutas protegidas con autenticación
Route::middleware('auth:sanctum')->group(function () {
    // Información del usuario autenticado
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Ruta de logout
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    
    // Información del usuario autenticado
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Grupo de rutas para reportes
    Route::prefix('reports')->group(function () {
        // Reporte A: Listado de Personas por Cita
        Route::get('/personas-por-cita', [ReportController::class, 'personasPorCita']);
        Route::get('/clients-by-appointment', [ReportController::class, 'personasPorCita']);
        
        // Reporte B: Listado de Personas con Atenciones y Servicios
        Route::get('/personas-atenciones-servicios', [ReportController::class, 'personasAtencionesServicios']);
        Route::get('/clients-attentions-services', [ReportController::class, 'personasAtencionesServicios']);
        
        // Reporte C: Citas y Ventas por Persona
        Route::get('/citas-ventas', [ReportController::class, 'citasVentasPorPersona']);
        Route::get('/client-sales', [ReportController::class, 'citasVentasPorPersona']);
        
        // Reporte D: Citas y Atenciones
        Route::get('/citas-atenciones', [ReportController::class, 'citasYAtenciones']);
        Route::get('/appointments-attentions', [ReportController::class, 'citasYAtenciones']);
        
        // Reporte Consolidado (Dashboard)
        Route::get('/consolidado', [ReportController::class, 'reporteConsolidado']);
        Route::get('/consolidated', [ReportController::class, 'reporteConsolidado']);
        
        // Exportar reporte a CSV
        Route::get('/export', [ReportController::class, 'exportarCSV']);
    });
});
