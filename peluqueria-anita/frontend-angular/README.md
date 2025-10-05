# 💇‍♀️ Peluquería Anita - Frontend Angular

Sistema de gestión integral para salón de belleza desarrollado con Angular 17 y Bootstrap 5.

## 🚀 Descripción del Proyecto

**Peluquería Anita** es una aplicación web moderna diseñada para automatizar y optimizar la gestión completa de un salón de belleza. El frontend Angular proporciona una interfaz intuitiva y responsive para la administración de clientes, servicios, citas y pagos.

## ✨ Características Principales

### 🔐 **Sistema de Autenticación**
- Login/logout seguro con JWT tokens
- Gestión de roles (Admin, Estilista, Cliente)
- Protección de rutas con guards
- Actualización de perfil de usuario

### 👥 **Gestión de Clientes**
- CRUD completo de clientes
- Búsqueda y filtrado avanzado
- Paginación de resultados
- Historial de citas por cliente
- Estadísticas de clientes frecuentes

### 💇‍♀️ **Gestión de Servicios**
- Catálogo completo de servicios
- Categorización por tipo (Cortes, Coloración, Tratamientos, etc.)
- Control de precios y duración
- Servicios más populares
- Estado activo/inactivo

### 📅 **Sistema de Citas**
- Calendario interactivo para programar citas
- Verificación de disponibilidad en tiempo real
- Múltiples servicios por cita
- Gestión de estados (pendiente, confirmada, completada, etc.)
- Horarios disponibles por estilista
- Notificaciones y recordatorios

### 💰 **Sistema de Pagos**
- Registro de pagos por cita
- Múltiples métodos de pago (efectivo, tarjeta, transferencia)
- Generación de recibos
- Control de estados de pago
- Sistema de reembolsos

### 📊 **Dashboard Analítico**
- Estadísticas generales del negocio
- Gráficos de ingresos diarios/mensuales
- Análisis de servicios más populares
- Performance por estilista
- KPIs del negocio

## 🛠️ Tecnologías Utilizadas

### **Framework Principal**
- **Angular 17**: Framework principal con las últimas características
- **Angular CLI**: Herramientas de desarrollo y build
- **TypeScript**: Lenguaje principal para type safety

### **UI/UX**
- **Bootstrap 5**: Framework CSS para diseño responsive
- **Angular Bootstrap**: Componentes Bootstrap nativos para Angular
- **Font Awesome**: Iconografía moderna
- **CSS Custom Properties**: Variables CSS para theming

### **Estado y Datos**
- **Angular Services**: Gestión de estado y lógica de negocio
- **RxJS**: Programación reactiva y manejo de observables
- **HttpClient**: Cliente HTTP para comunicación con API

### **Routing y Navegación**
- **Angular Router**: Sistema de rutas con lazy loading
- **Route Guards**: Protección de rutas por autenticación y roles
- **Resolvers**: Pre-carga de datos para rutas

## 📁 Estructura del Proyecto

```
src/
├── app/
│   ├── components/           # Componentes reutilizables
│   │   ├── navbar/          # Barra de navegación
│   │   └── sidebar/         # Menú lateral
│   ├── pages/               # Páginas principales
│   │   ├── login/           # Página de login
│   │   ├── dashboard/       # Dashboard principal
│   │   ├── clients/         # Gestión de clientes
│   │   ├── services/        # Gestión de servicios
│   │   ├── appointments/    # Gestión de citas
│   │   └── payments/        # Gestión de pagos
│   ├── services/            # Servicios Angular
│   │   ├── auth.service.ts  # Autenticación
│   │   ├── client.service.ts # Gestión de clientes
│   │   ├── service.service.ts # Gestión de servicios
│   │   ├── appointment.service.ts # Gestión de citas
│   │   └── payment.service.ts # Gestión de pagos
│   ├── guards/              # Route Guards
│   │   └── auth.guard.ts    # Guard de autenticación
│   ├── interfaces/          # Interfaces TypeScript
│   │   ├── user.interface.ts
│   │   ├── client.interface.ts
│   │   ├── service.interface.ts
│   │   ├── appointment.interface.ts
│   │   └── payment.interface.ts
│   ├── environments/        # Configuración de entornos
│   └── assets/             # Recursos estáticos
├── styles/                 # Estilos globales
└── index.html             # HTML principal
```

## 🚀 Instalación y Configuración

### **Prerrequisitos**
- Node.js 18+ y npm
- Angular CLI 17+
- Backend Laravel funcionando en puerto 8000

### **Pasos de Instalación**

1. **Clonar el repositorio**
```bash
cd frontend-angular
```

2. **Instalar dependencias**
```bash
npm install
```

3. **Configurar variables de entorno**
```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8000/api'
};
```

4. **Iniciar servidor de desarrollo**
```bash
npm start
# o
ng serve
```

5. **Acceder a la aplicación**
```
http://localhost:4200
```

## 👤 Usuarios de Prueba

### **Administrador**
- **Email:** `anita@peluqueria.com`
- **Contraseña:** `password123`
- **Rol:** Admin - Acceso completo al sistema

### **Estilistas**
- **Email:** `maria@peluqueria.com` | **Contraseña:** `password123`
- **Email:** `carlos@peluqueria.com` | **Contraseña:** `password123`
- **Rol:** Stylist - Gestión de sus citas y servicios

## 📱 Características de UI/UX

### **Diseño Responsive**
- ✅ Compatible con dispositivos móviles, tablets y desktop
- ✅ Navegación adaptativa según el tamaño de pantalla
- ✅ Componentes optimizados para touch

### **Experiencia de Usuario**
- ✅ Interfaz intuitiva y fácil de usar
- ✅ Feedback visual para todas las acciones
- ✅ Loading states y mensajes informativos
- ✅ Validación de formularios en tiempo real

### **Tema y Branding**
- ✅ Paleta de colores profesional para salón de belleza
- ✅ Tipografía moderna y legible
- ✅ Iconografía consistente
- ✅ Animaciones suaves y elegantes

## 🔧 Scripts Disponibles

### **Desarrollo**
```bash
npm start              # Servidor de desarrollo
npm run build          # Build para producción
npm run build:dev      # Build para desarrollo
npm run watch          # Build en modo watch
```

### **Testing**
```bash
npm test              # Tests unitarios
npm run test:watch    # Tests en modo watch
npm run e2e           # Tests end-to-end
```

### **Calidad de Código**
```bash
npm run lint          # Linting con ESLint
npm run lint:fix      # Fix automático de lint
```

## 🌐 Integración con Backend

### **API Base URL**
```typescript
const API_URL = 'http://localhost:8000/api';
```

### **Endpoints Principales**
```typescript
// Autenticación
POST /auth/login
POST /auth/logout
GET /auth/user

// Clientes
GET /clients
POST /clients
PUT /clients/:id
DELETE /clients/:id

// Servicios
GET /services
POST /services
PUT /services/:id
DELETE /services/:id

// Citas
GET /appointments
POST /appointments
PUT /appointments/:id
PATCH /appointments/:id/status
GET /appointments/available-slots

// Pagos
GET /payments
POST /payments
PUT /payments/:id

// Dashboard
GET /dashboard/stats
```

### **Autenticación**
- JWT tokens almacenados en localStorage
- Interceptor HTTP para agregar tokens automáticamente
- Renovación automática de tokens
- Logout automático en caso de token expirado

## 📊 Funcionalidades por Módulo

### **Dashboard**
- Resumen de estadísticas del día
- Gráficos de ingresos y citas
- Citas próximas y del día
- KPIs principales del negocio

### **Clientes**
- Lista con búsqueda y filtros
- Formulario de registro/edición
- Historial de citas por cliente
- Estadísticas de cliente frecuente

### **Servicios**
- Catálogo con categorías
- Control de precios y duración
- Estados activo/inactivo
- Análisis de popularidad

### **Citas**
- Calendario interactivo
- Programación paso a paso
- Verificación de disponibilidad
- Gestión de estados múltiples

### **Pagos**
- Registro de transacciones
- Múltiples métodos de pago
- Generación de recibos
- Control de estado de pagos

## 🔒 Seguridad

### **Autenticación y Autorización**
- ✅ JWT tokens seguros
- ✅ Guards de autenticación en rutas
- ✅ Validación de roles por componente
- ✅ Logout automático por inactividad

### **Validación de Datos**
- ✅ Validación en formularios (client-side)
- ✅ Sanitización de inputs
- ✅ Validación de tipos TypeScript
- ✅ Manejo seguro de errores

## 🚀 Deploy y Producción

### **Build para Producción**
```bash
npm run build
```

### **Variables de Producción**
```typescript
// src/environments/environment.prod.ts
export const environment = {
  production: true,
  apiUrl: 'https://api.peluqueria-anita.com/api'
};
```

### **Optimizaciones**
- ✅ Lazy loading de módulos
- ✅ Tree shaking automático
- ✅ Compresión de assets
- ✅ Service Workers para PWA

## 🤝 Contribución

### **Estándares de Código**
- ESLint configurado con reglas de Angular
- Prettier para formateo automático
- Conventional Commits para mensajes
- Arquitectura modular y escalable

### **Flujo de Desarrollo**
1. Fork del proyecto
2. Crear rama feature
3. Desarrollar funcionalidad
4. Tests y validaciones
5. Pull request con descripción detallada

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 👨‍💻 Desarrollado por

**Peluquería Anita Team**
- Sistema integral de gestión para salones de belleza
- Tecnología moderna y escalable
- Enfoque en experiencia de usuario

---

## 📞 Soporte

Para soporte técnico o consultas:
- **Email:** support@peluqueria-anita.com
- **Documentación:** [docs.peluqueria-anita.com](https://docs.peluqueria-anita.com)

---

*Desarrollado con ❤️ y Angular 17*
