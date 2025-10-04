#!/bin/bash
# Build script para Render.com

set -o errexit

echo "📦 Instalando dependencias de Composer..."
composer install --no-dev --optimize-autoloader

echo "🔑 Generando application key..."
php artisan key:generate --force

echo "🗄️ Ejecutando migraciones..."
php artisan migrate --force

echo "📋 Ejecutando seeders..."
php artisan db:seed --force

echo "⚙️ Optimizando configuración..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "✅ Build completado!"
