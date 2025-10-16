<?php

use Illuminate\Support\Facades\Route;

/**
 * ====================================================================
 * WEB ROUTES - SISTEMA DE REPORTERÍA DFS
 * ====================================================================
 */

Route::get('/', function () {
    return response()->json([
        'name' => 'Reportería DFS API',
        'version' => '1.0.0',
        'description' => 'Sistema de Reportería Full Stack',
        'author' => 'Diego González',
        'endpoints' => [
            'health' => '/api/health',
            'reports' => '/api/reports',
            'documentation' => 'Ver README.md'
        ]
    ]);
});
