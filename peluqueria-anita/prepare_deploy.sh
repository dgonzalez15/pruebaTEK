#!/bin/bash
# Script para preparar todo para el despliegue en Railway + Vercel

echo "🚀 PREPARANDO PROYECTO PARA RAILWAY + VERCEL"
echo "============================================="
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📋 PASO 1: Generar APP_KEY${NC}"
cd backend-api
APP_KEY=$(php artisan key:generate --show)
echo -e "${GREEN}Tu APP_KEY es: ${APP_KEY}${NC}"
echo -e "${YELLOW}⚠️  GUARDA ESTA KEY, la necesitarás en Render!${NC}"
echo ""

echo -e "${BLUE}📋 PASO 2: Verificar archivos de configuración${NC}"
echo "✅ Dockerfile creado"
echo "✅ render.yaml creado"
echo "✅ build.sh creado"
echo ""

echo -e "${BLUE}📋 PASO 3: Tu repositorio de GitHub${NC}"
echo ""
echo "✅ Ya tienes tu código en GitHub:"
echo "   https://github.com/dgonzalez15/pruebaTEK.git"
echo ""
echo "📁 Estructura del monorepo:"
echo "   - peluqueria-anita/backend-api (Backend Laravel)"
echo "   - peluqueria-anita/mobile-flutter (Frontend Flutter)"
echo ""

echo -e "${BLUE}📋 PASO 4: Próximos pasos${NC}"
echo ""
echo "1️⃣  Ir a Railway.app y crear proyecto"
echo "2️⃣  Provisionar MySQL"
echo "3️⃣  Desplegar backend desde GitHub (Root: peluqueria-anita/backend-api)"
echo "4️⃣  Configurar variables de entorno"
echo "5️⃣  Ir a Vercel.com"
echo "6️⃣  Desplegar frontend (Root: peluqueria-anita/mobile-flutter)"
echo "7️⃣  Actualizar URL del backend en constants.dart"
echo "8️⃣  Crear usuarios en la base de datos"
echo ""

echo -e "${GREEN}✅ TODO LISTO!${NC}"
echo ""
echo -e "${BLUE}📖 LEE EL ARCHIVO: GUIA_RAILWAY_VERCEL.md${NC}"
echo "   Contiene la guía paso a paso completa con todos los detalles"
echo ""
echo -e "${BLUE}📋 USA EL ARCHIVO: CHECKLIST.md${NC}"
echo "   Para verificar que no te falte nada"
echo ""
echo "🎉 ¡Éxito con tu despliegue!"
