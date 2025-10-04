#!/bin/bash
# Build script para Flutter Web en Render

set -o errexit

echo "🎯 Instalando Flutter..."

# Descargar Flutter
if [ ! -d "flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Agregar Flutter al PATH
export PATH="$PATH:`pwd`/flutter/bin"

echo "📦 Flutter doctor..."
flutter doctor -v

echo "📦 Obteniendo dependencias..."
flutter pub get

echo "🌐 Construyendo Flutter Web..."
flutter build web --release --web-renderer html

echo "✅ Build completado! Archivos en build/web"
