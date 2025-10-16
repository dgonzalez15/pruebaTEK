# Sistema de Reportería DFS - Frontend Angular 18

Sistema de reportería para Peluquería Anita desarrollado con Angular 18, Angular Material y Chart.js.

## 📋 Características

- ✅ Login con autenticación JWT
- ✅ Dashboard consolidado con métricas y gráficos
- ✅ 4 Tipos de reportes personalizados (A, B, C, D)
- ✅ Filtros por fechas y estado
- ✅ Exportación a CSV
- ✅ Diseño responsive con Angular Material
- ✅ Gráficos interactivos con Chart.js
- ✅ Paginación de datos
- ✅ Guards de autenticación
- ✅ Interceptors HTTP

## 🛠️ Tecnologías

- **Angular 18** - Framework frontend
- **Angular Material 18** - Componentes UI
- **Chart.js 4.4** - Gráficos y visualizaciones
- **RxJS 7.8** - Programación reactiva
- **TypeScript 5.4** - Lenguaje de programación

## 📁 Estructura del Proyecto

```
frontend/
├── src/
│   ├── app/
│   │   ├── components/          # Componentes reutilizables
│   │   │   └── layout/          # Layout principal con navbar
│   │   ├── pages/               # Páginas principales
│   │   │   ├── login/           # Página de login
│   │   │   ├── dashboard/       # Dashboard consolidado
│   │   │   └── reports/         # Páginas de reportes A, B, C, D
│   │   ├── services/            # Servicios
│   │   │   ├── auth.service.ts
│   │   │   └── report.service.ts
│   │   ├── guards/              # Guards de rutas
│   │   │   └── auth.guard.ts
│   │   ├── interceptors/        # Interceptors HTTP
│   │   │   └── auth.interceptor.ts
│   │   ├── types/               # Interfaces y tipos TypeScript
│   │   │   └── reports.types.ts
│   │   ├── app.component.ts     # Componente raíz
│   │   ├── app.config.ts        # Configuración de la app
│   │   └── app.routes.ts        # Configuración de rutas
│   ├── environments/            # Variables de entorno
│   ├── assets/                  # Archivos estáticos
│   ├── index.html              # HTML principal
│   ├── main.ts                 # Punto de entrada
│   └── styles.scss             # Estilos globales
├── angular.json                # Configuración de Angular CLI
├── package.json                # Dependencias del proyecto
├── tsconfig.json               # Configuración de TypeScript
└── README.md                   # Este archivo
```

## 🚀 Instalación y Ejecución

### Prerrequisitos

- Node.js 18+
- npm o pnpm

### Pasos

1. **Instalar dependencias:**
   ```bash
   cd frontend
   npm install
   ```

2. **Configurar variables de entorno:**

   Edita `src/environments/environment.ts` y configura la URL de tu API:
   ```typescript
   export const environment = {
     production: false,
     apiUrl: 'http://localhost:8000/api'  // URL de tu backend Laravel
   };
   ```

3. **Ejecutar en modo desarrollo:**
   ```bash
   npm start
   ```

   La aplicación estará disponible en `http://localhost:4200`

4. **Compilar para producción:**
   ```bash
   npm run build
   ```

   Los archivos compilados estarán en `dist/`

## 👤 Credenciales por Defecto

```
Email: admin@dfs.com
Contraseña: password123
```

## 📊 Reportes Disponibles

### Dashboard Consolidado
- Métricas generales (clientes, citas, atenciones, ventas)
- Gráfico de citas por estado
- Gráfico de servicios más solicitados
- Top clientes con más citas
- Filtrado por rango de fechas

### Reporte A: Clientes por Cita
- Listado de todas las citas con información del cliente
- Filtros: Fechas, Estado, Cliente específico
- Paginación
- Exportación a CSV

### Reporte B: Clientes, Atenciones y Servicios
- Vista detallada de clientes con sus atenciones
- Servicios recibidos por cada cliente
- Resumen de totales
- Exportación a CSV

### Reporte C: Ventas por Cliente
- Reporte de ventas agrupado por cliente
- Histórico de citas y montos gastados
- Total de servicios contratados
- Exportación a CSV

### Reporte D: Citas y Atenciones
- Relación entre citas agendadas y atenciones realizadas
- Estado de cada cita
- Tasa de asistencia
- Exportación a CSV

## 🔒 Autenticación

El sistema utiliza autenticación JWT (JSON Web Tokens):

1. El usuario ingresa email y contraseña
2. El backend valida las credenciales y retorna un token
3. El token se almacena en localStorage
4. Todas las peticiones HTTP incluyen el token en el header Authorization
5. El AuthGuard protege las rutas que requieren autenticación

## 🎨 Personalización

### Cambiar tema de colores

Edita `src/styles.scss` y modifica los colores de Angular Material:

```scss
@use '@angular/material' as mat;

$my-primary: mat.define-palette(mat.$indigo-palette);
$my-accent: mat.define-palette(mat.$pink-palette);
```

### Agregar nuevos reportes

1. Crea la interfaz en `src/app/types/reports.types.ts`
2. Agrega el método en `src/app/services/report.service.ts`
3. Crea el componente en `src/app/pages/reports/`
4. Registra la ruta en `src/app/app.routes.ts`

## 📝 Scripts Disponibles

```bash
npm start          # Inicia el servidor de desarrollo
npm run build      # Compila la aplicación para producción
npm run watch      # Compila y observa cambios
npm test           # Ejecuta las pruebas
```

## 🐛 Troubleshooting

### Error de CORS
Si recibes errores de CORS, asegúrate de que tu backend Laravel tenga configurado correctamente el middleware CORS para permitir peticiones desde `http://localhost:4200`.

### Error de conexión a la API
Verifica que:
1. El backend esté corriendo en `http://localhost:8000`
2. La URL en `environment.ts` sea correcta
3. No haya firewalls bloqueando la conexión

### Errores de compilación TypeScript
Ejecuta:
```bash
npm install
rm -rf node_modules package-lock.json
npm install
```

## 📄 Licencia

Este proyecto es privado y confidencial.

## 👨‍💻 Autor

**Diego González**
Prueba Técnica DFS - 2025

---

**Nota:** Este sistema fue desarrollado como parte de la prueba técnica para el cargo de Desarrollador Full Stack en DFS.
