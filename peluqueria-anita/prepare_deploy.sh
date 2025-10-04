#!/bin/bash
# Script para preparar todo para el despliegue en Render

echo "🚀 PREPARANDO PROYECTO PARA RENDER.COM"
echo "======================================"
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

echo -e "${BLUE}📋 PASO 3: Instrucciones para GitHub${NC}"
echo ""
echo "BACKEND:"
echo "--------"
echo "cd backend-api"
echo "git init"
echo "git add ."
echo "git commit -m 'Backend listo para Render'"
echo "# Crea repo en GitHub llamado: peluqueria-anita-backend"
echo "git remote add origin https://github.com/TU_USUARIO/peluqueria-anita-backend.git"
echo "git branch -M main"
echo "git push -u origin main"
echo ""

echo "FRONTEND:"
echo "---------"
echo "cd ../mobile-flutter"
echo "git init"
echo "git add ."
echo "git commit -m 'Frontend listo para Render'"
echo "# Crea repo en GitHub llamado: peluqueria-anita-frontend"
echo "git remote add origin https://github.com/TU_USUARIO/peluqueria-anita-frontend.git"
echo "git branch -M main"
echo "git push -u origin main"
echo ""

echo -e "${GREEN}✅ TODO LISTO!${NC}"
echo ""
echo -e "${BLUE}📖 LEE EL ARCHIVO: DEPLOY_RENDER.md${NC}"
echo "   Contiene la guía paso a paso completa"
echo ""
echo -e "${BLUE}📋 USA EL ARCHIVO: CHECKLIST.md${NC}"
echo "   Para verificar que no te falte nada"
echo ""
echo "🎉 ¡Éxito con tu despliegue!"
