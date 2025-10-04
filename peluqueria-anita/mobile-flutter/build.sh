#!/bin/bash

echo "🚀 Construyendo Peluquería Anita para producción..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. Limpiar build anterior
echo -e "${BLUE}🧹 Limpiando builds anteriores...${NC}"
flutter clean

# 2. Obtener dependencias
echo -e "${BLUE}📦 Obteniendo dependencias...${NC}"
flutter pub get

# 3. Construir para web
echo -e "${BLUE}🌐 Construyendo Flutter Web...${NC}"
flutter build web --release --web-renderer html

# 4. Verificar que el build se completó
if [ -d "build/web" ]; then
    echo -e "${GREEN}✅ Build completado exitosamente!${NC}"
    echo -e "${GREEN}📁 Los archivos están en: build/web${NC}"
    echo ""
    echo -e "${BLUE}📝 Próximos pasos:${NC}"
    echo "1. Ve a vercel.com"
    echo "2. Importa este proyecto"
    echo "3. Configura:"
    echo "   - Build Command: flutter build web --release"
    echo "   - Output Directory: build/web"
    echo "4. Deploy!"
else
    echo -e "${RED}❌ Error: No se pudo completar el build${NC}"
    exit 1
fi
