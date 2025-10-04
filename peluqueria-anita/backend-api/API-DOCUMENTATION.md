# 🚀 API Peluquería Anita - Documentación v2.0

## 📋 Nuevas Funcionalidades Implementadas

### ✅ **CRUD Completo - Clientes**
### ✅ **CRUD Completo - Citas** 
### ✅ **CRUD Completo - Atenciones**

---

## 🛠️ **ENDPOINTS DISPONIBLES**

### 🔐 **Autenticación**
```
POST   /api/auth/register        - Registrar usuario
POST   /api/auth/login           - Iniciar sesión
POST   /api/auth/logout          - Cerrar sesión
GET    /api/auth/user            - Obtener usuario actual
PUT    /api/auth/profile         - Actualizar perfil
```

---

## 👥 **CLIENTES - CRUD Completo**

### **Endpoints Básicos**
```
GET    /api/clients              - Listar clientes (con paginación y filtros)
POST   /api/clients              - Crear cliente
GET    /api/clients/{id}         - Obtener cliente específico
PUT    /api/clients/{id}         - Actualizar cliente
DELETE /api/clients/{id}         - Eliminar cliente
```

### **Endpoints Adicionales**
```
GET    /api/clients/stats                    - Estadísticas generales de clientes
PATCH  /api/clients/{id}/toggle-status       - Activar/desactivar cliente
GET    /api/clients/{id}/appointments        - Historial de citas del cliente
```

### **Parámetros de Filtrado (GET /api/clients)**
```
?search=texto           - Buscar por nombre, email o teléfono
?is_active=true|false   - Filtrar por estado activo
?gender=male|female|other - Filtrar por género
?sort_by=name|created_at  - Ordenar por campo
?sort_order=asc|desc      - Dirección del ordenamiento
?per_page=15              - Elementos por página
```

### **Ejemplo de Respuesta Cliente**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "María García",
    "email": "maria@example.com",
    "phone": "+1234567890",
    "address": "Calle Principal 123",
    "birth_date": "1990-05-15",
    "gender": "female",
    "notes": "Cliente preferencial",
    "is_active": true,
    "appointments_count": 5,
    "total_spent": 250.00,
    "last_appointment": "2025-10-01"
  }
}
```

---

## 📅 **CITAS - CRUD Completo**

### **Endpoints Básicos**
```
GET    /api/appointments         - Listar citas
POST   /api/appointments         - Crear cita
GET    /api/appointments/{id}    - Obtener cita específica
PUT    /api/appointments/{id}    - Actualizar cita
DELETE /api/appointments/{id}    - Eliminar cita
```

### **Endpoints Adicionales**
```
GET    /api/appointments/today                      - Citas del día
GET    /api/appointments/available-slots            - Horarios disponibles
GET    /api/appointments/search                     - Buscar citas por cliente
GET    /api/appointments/stats                      - Estadísticas de citas
PATCH  /api/appointments/{id}/status                - Cambiar estado
PATCH  /api/appointments/{id}/confirm               - Confirmar cita
PATCH  /api/appointments/{id}/complete              - Marcar como completada
PATCH  /api/appointments/{id}/cancel                - Cancelar cita
PATCH  /api/appointments/{id}/reschedule            - Reprogramar cita
```

### **Parámetros de Filtrado (GET /api/appointments)**
```
?date=2025-10-04            - Filtrar por fecha específica
?date_from=2025-10-01       - Desde fecha
?date_to=2025-10-31         - Hasta fecha
?user_id=2                  - Filtrar por estilista
?client_id=1                - Filtrar por cliente
?status=pending|confirmed|completed|cancelled
?search=texto               - Buscar por cliente
```

### **Estados de Cita**
- `pending` - Pendiente
- `confirmed` - Confirmada
- `in_progress` - En progreso
- `completed` - Completada
- `cancelled` - Cancelada
- `no_show` - No se presentó

---

## 💇‍♀️ **ATENCIONES - CRUD Completo (NUEVO)**

### **Endpoints Básicos**
```
GET    /api/attentions           - Listar atenciones
POST   /api/attentions           - Crear atención
GET    /api/attentions/{id}      - Obtener atención específica
PUT    /api/attentions/{id}      - Actualizar atención
DELETE /api/attentions/{id}      - Eliminar atención
```

### **Endpoints Adicionales**
```
GET    /api/attentions/stats                - Estadísticas de atenciones
PATCH  /api/attentions/{id}/status          - Cambiar estado de atención
```

### **Parámetros de Filtrado (GET /api/attentions)**
```
?date=2025-10-04            - Filtrar por fecha
?status=started|in_progress|completed|cancelled
?stylist_id=2               - Filtrar por estilista
?client_id=1                - Filtrar por cliente
?search=texto               - Buscar por cliente
?sort_by=attention_date     - Ordenar por campo
?sort_order=desc            - Dirección del ordenamiento
?per_page=15                - Elementos por página
```

### **Estructura de Atención**
```json
{
  "id": 1,
  "appointment_id": 1,
  "client_id": 1,
  "user_id": 2,
  "service_id": 1,
  "attention_date": "2025-10-04",
  "start_time": "09:00",
  "end_time": "09:30",
  "status": "completed",
  "service_price": 25.00,
  "observations": "Cliente muy satisfecho con el corte",
  "products_used": "Shampoo clarificante, acondicionador",
  "tip_amount": 5.00,
  "client_satisfaction": "very_satisfied",
  "notes": "Cliente frecuente",
  "client": { /* datos del cliente */ },
  "stylist": { /* datos del estilista */ },
  "service": { /* datos del servicio */ },
  "appointment": { /* datos de la cita */ }
}
```

### **Estados de Atención**
- `started` - Iniciada
- `in_progress` - En progreso
- `completed` - Completada
- `cancelled` - Cancelada

### **Niveles de Satisfacción**
- `very_unsatisfied` - Muy insatisfecho
- `unsatisfied` - Insatisfecho
- `neutral` - Neutral
- `satisfied` - Satisfecho
- `very_satisfied` - Muy satisfecho

---

## 💰 **PAGOS**
```
GET    /api/payments             - Listar pagos
POST   /api/payments             - Crear pago
GET    /api/payments/{id}        - Obtener pago
PUT    /api/payments/{id}        - Actualizar pago
DELETE /api/payments/{id}        - Eliminar pago
```

---

## 💇‍♀️ **SERVICIOS**
```
GET    /api/services             - Listar servicios
POST   /api/services             - Crear servicio
GET    /api/services/{id}        - Obtener servicio
PUT    /api/services/{id}        - Actualizar servicio
DELETE /api/services/{id}        - Eliminar servicio
GET    /api/services/popular     - Servicios populares
```

---

## 📊 **DASHBOARD Y ESTADÍSTICAS**
```
GET    /api/dashboard/stats           - Estadísticas generales
GET    /api/dashboard/monthly-overview - Resumen mensual
GET    /api/dashboard/quick-stats     - Estadísticas rápidas
```

---

## 👨‍💼 **ESTILISTAS**
```
GET    /api/stylists             - Listar estilistas disponibles
```

---

## 🔍 **HEALTH CHECK**
```
GET    /api/health               - Estado de la API
```

### **Respuesta Health Check**
```json
{
  "status": "ok",
  "message": "API Peluquería Anita funcionando correctamente",
  "timestamp": "2025-10-04T04:00:00.000Z",
  "version": "2.0.0",
  "features": {
    "clients_crud": "enabled",
    "appointments_crud": "enabled", 
    "attentions_crud": "enabled",
    "advanced_stats": "enabled"
  }
}
```

---

## 🔒 **AUTENTICACIÓN**

Todas las rutas (excepto `/auth/login`, `/auth/register` y `/health`) requieren autenticación mediante token Bearer JWT.

### **Headers Requeridos**
```
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

---

## 📝 **USUARIOS DE PRUEBA**

### **Administrador**
- **Email:** `anita@peluqueria.com`
- **Password:** `password123`
- **Rol:** `admin`

### **Estilistas**
- **Email:** `maria@peluqueria.com` | **Password:** `password123` | **Rol:** `stylist`
- **Email:** `carlos@peluqueria.com` | **Password:** `password123` | **Rol:** `stylist`

---

## 📊 **DATOS DE PRUEBA DISPONIBLES**

### **Clientes:** 3 clientes registrados
### **Servicios:** 8 servicios disponibles
### **Citas:** 2 citas programadas
### **Atenciones:** 5 atenciones registradas
### **Usuarios:** 3 usuarios (1 admin + 2 estilistas)

---

## 🚀 **SERVIDOR LOCAL**

La API está configurada para ejecutarse en:
```
http://localhost:8000
```

### **Base de Datos**
- **Motor:** MySQL 9.4.0
- **Base de Datos:** `peluqueria_anita`
- **Host:** `localhost`
- **Puerto:** `3306`

---

## 📱 **EJEMPLOS DE USO**

### **1. Obtener Token de Autenticación**
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "anita@peluqueria.com",
    "password": "password123"
  }'
```

### **2. Listar Clientes**
```bash
curl -X GET http://localhost:8000/api/clients \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

### **3. Crear Nueva Atención**
```bash
curl -X POST http://localhost:8000/api/attentions \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "appointment_id": 1,
    "client_id": 1,
    "user_id": 2,
    "service_id": 1,
    "attention_date": "2025-10-04",
    "start_time": "10:00",
    "end_time": "10:30",
    "status": "started",
    "service_price": 25.00,
    "observations": "Cliente nuevo"
  }'
```

### **4. Obtener Estadísticas**
```bash
curl -X GET http://localhost:8000/api/attentions/stats \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

---

## ✅ **FUNCIONALIDADES IMPLEMENTADAS**

### **✅ CRUD Completo de Clientes**
- Crear, leer, actualizar, eliminar
- Filtrado y búsqueda avanzada
- Estadísticas y métricas
- Historial de citas
- Activar/desactivar

### **✅ CRUD Completo de Citas**
- Gestión completa de citas
- Estados múltiples
- Búsqueda y filtrado
- Reprogramación
- Confirmación y cancelación
- Estadísticas detalladas

### **✅ CRUD Completo de Atenciones**
- Registro detallado de servicios
- Seguimiento de satisfacción del cliente
- Control de productos utilizados
- Gestión de propinas
- Observaciones y notas
- Estados de progreso

### **✅ Integración MySQL**
- Base de datos optimizada
- Relaciones bien definidas
- Índices para rendimiento
- Datos de prueba completos

---

**🎉 Sistema completo con CRUD funcional para Clientes, Citas y Atenciones conectado a MySQL!**