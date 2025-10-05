# 💈 Peluquería Anita - Sistema de Gestión

Sistema completo de gestión para peluquería con frontend Flutter Web, backend Laravel y arquitectura de microservicios desplegada en la nube.

## 📋 Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Configuración y Despliegue](#configuración-y-despliegue)
- [Base de Datos](#base-de-datos)
- [API Endpoints](#api-endpoints)
- [Desarrollo Local](#desarrollo-local)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Descripción General

**Peluquería Anita** es un sistema integral para la gestión de un salón de belleza que permite:

- ✅ Gestión de clientes
- ✅ Gestión de servicios (cortes, tintes, etc.)
- ✅ Agendamiento de citas
- ✅ Control de atenciones realizadas
- ✅ Registro de pagos
- ✅ Sistema de autenticación con roles (admin, stylist, client)
- ✅ Dashboard administrativo

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                        FRONTEND                             │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │  Flutter Web     │         │ Angular (futuro) │         │
│  │  (Vercel)        │         │                  │         │
│  └────────┬─────────┘         └──────────────────┘         │
│           │                                                  │
│           │ HTTPS/REST                                       │
│           ▼                                                  │
└───────────────────────────────────────────────────────────────┘
            │
            │
┌───────────▼───────────────────────────────────────────────────┐
│                    BACKEND API                                │
│  ┌─────────────────────────────────────────────────────┐     │
│  │          Laravel 11 (PHP 8.2.27)                    │     │
│  │          Railway (pruebatek-production)             │     │
│  └──────────────────┬──────────────────────────────────┘     │
└────────────────────┼──────────────────────────────────────────┘
                     │
                     │
┌────────────────────▼──────────────────────────────────────────┐
│                    BASE DE DATOS                              │
│  ┌────────────────────────┐  ┌──────────────────────────┐    │
│  │   PostgreSQL 17        │  │      MySQL 8 (Local)     │    │
│  │   Railway (Producción) │  │   Desarrollo Local       │    │
│  └────────────────────────┘  └──────────────────────────┘    │
└───────────────────────────────────────────────────────────────┘
```

### Flujo de Datos

1. **Usuario accede** → Frontend (Vercel)
2. **Frontend solicita datos** → Backend API (Railway)
3. **Backend procesa** → PostgreSQL (Railway - Producción)
4. **Backend responde** → Frontend
5. **Frontend renderiza** → Usuario

---

## 💻 Tecnologías Utilizadas

### Frontend
- **Flutter 3.24.x** - Framework multiplataforma
  - Dart SDK
  - Material Design 3
  - HTTP package para API calls
  - Provider/Riverpod para state management

- **Angular 18** (en desarrollo)
  - TypeScript
  - Standalone components
  - RxJS para programación reactiva

### Backend
- **Laravel 11** - Framework PHP
  - PHP 8.2.27
  - Laravel Sanctum (autenticación API)
  - Eloquent ORM
  - Migraciones y Seeders

### Base de Datos
- **PostgreSQL 17** (Producción en Railway)
  - Relacional
  - ACID compliant
  - Soporte JSON
  
- **MySQL 8** (Desarrollo Local)
  - Compatible con Laravel
  - Para desarrollo y testing

### Infraestructura y DevOps
- **Railway** - Plataforma de despliegue backend
  - Auto-deployment desde GitHub
  - Environment variables management
  - PostgreSQL managed database
  
- **Vercel** - Hosting frontend
  - Deploy automático desde Git
  - CDN global
  - SSL automático

- **GitHub** - Control de versiones
  - Repositorio: `dgonzalez15/pruebaTEK`
  - Branch principal: `main`

### Herramientas de Desarrollo
- Railway CLI
- Git
- Composer (PHP)
- npm/pnpm (Node.js)
- VS Code

---

## 📁 Estructura del Proyecto

```
prueba/
│
└── peluqueria-anita/
    ├── backend-api/              # Laravel Backend
    │   ├── app/
    │   │   ├── Http/
    │   │   │   ├── Controllers/
    │   │   │   │   ├── Api/
    │   │   │   │   │   ├── AuthController.php
    │   │   │   │   │   ├── ClientController.php
    │   │   │   │   │   ├── ServiceController.php
    │   │   │   │   │   ├── AppointmentController.php
    │   │   │   │   │   ├── AttentionController.php
    │   │   │   │   │   └── PaymentController.php
    │   │   │   │   └── Middleware/
    │   │   │   └── Requests/
    │   │   └── Models/
    │   │       ├── User.php
    │   │       ├── Client.php
    │   │       ├── Service.php
    │   │       ├── Appointment.php
    │   │       ├── Attention.php
    │   │       └── Payment.php
    │   ├── config/
    │   │   ├── database.php       # ⚙️ Configuración DB dual
    │   │   ├── cors.php
    │   │   └── sanctum.php
    │   ├── database/
    │   │   ├── migrations/        # 📊 Esquema de BD
    │   │   └── seeders/
    │   ├── routes/
    │   │   ├── api.php           # 🔗 Rutas API
    │   │   └── web.php
    │   ├── .env                  # 🔐 Variables locales
    │   ├── railway.json          # 🚂 Config Railway
    │   └── composer.json
    │
    ├── mobile-flutter/           # Flutter Frontend
    │   ├── lib/
    │   │   ├── main.dart
    │   │   ├── models/
    │   │   ├── screens/
    │   │   ├── services/
    │   │   └── utils/
    │   │       └── constants.dart  # 🌐 URLs API
    │   ├── web/
    │   ├── pubspec.yaml
    │   └── README.md
    │
    └── frontend-angular/         # Angular Frontend (futuro)
        ├── src/
        ├── angular.json
        └── package.json
```

---

## ⚙️ Configuración y Despliegue

### 🔧 Variables de Entorno

#### Backend Local (`.env`)
```env
APP_NAME="Peluquería Anita"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost

# Base de datos LOCAL (MySQL)
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=peluqueria_anita
DB_USERNAME=root
DB_PASSWORD=

# Sesiones y cache
SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database
```

#### Backend Producción (Railway)
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://pruebatek-production.up.railway.app

# Base de datos PRODUCCIÓN (PostgreSQL)
DB_CONNECTION=pgsql
DATABASE_URL=postgresql://postgres:password@hopper.proxy.rlwy.net:39290/railway

# CORS
FRONTEND_URL=https://tu-app.vercel.app
```

### 🚀 Despliegue Backend (Railway)

1. **Conectar repositorio:**
```bash
cd backend-api
railway login
railway link
```

2. **Configurar variables:**
```bash
railway variables --set "DB_CONNECTION=pgsql"
railway variables --set "DATABASE_URL=${{PostgreSQL.DATABASE_PUBLIC_URL}}"
railway variables --set "APP_ENV=production"
railway variables --set "APP_DEBUG=false"
```

3. **Desplegar:**
```bash
git add .
git commit -m "feat: update backend"
git push origin main
# Railway auto-deploys
```

4. **Ejecutar migraciones:**
```bash
railway run php artisan migrate --force
```

### 🌐 Despliegue Frontend (Vercel)

1. **Conectar a Vercel:**
   - Ir a https://vercel.com
   - New Project → Import Git Repository
   - Seleccionar `dgonzalez15/pruebaTEK`
   - Root Directory: `peluqueria-anita/mobile-flutter`

2. **Build Settings:**
```
Framework: Flutter
Build Command: flutter build web
Output Directory: build/web
```

3. **Deploy automático:**
   - Cada push a `main` despliega automáticamente

---

## 🗄️ Base de Datos

### Diagrama de Entidades

```
┌─────────────┐         ┌──────────────┐
│    users    │         │   clients    │
├─────────────┤         ├──────────────┤
│ id          │         │ id           │
│ name        │         │ name         │
│ email       │         │ phone        │
│ password    │         │ email        │
│ role        │◄────┐   │ created_at   │
│ created_at  │     │   │ updated_at   │
└─────────────┘     │   └──────────────┘
                    │
                    │
                    │   ┌──────────────┐
                    └───│ appointments │
                        ├──────────────┤
                        │ id           │
                        │ client_id    │───┐
                        │ user_id      │   │
                        │ date         │   │
                        │ time         │   │
                        │ status       │   │
                        └──────────────┘   │
                                │          │
                                │          │
                    ┌───────────┴──────┐   │
                    │                  │   │
            ┌───────▼──────┐   ┌──────▼───▼───┐
            │  attentions  │   │   payments   │
            ├──────────────┤   ├──────────────┤
            │ id           │   │ id           │
            │ client_id    │   │ appointment_id│
            │ user_id      │   │ amount       │
            │ service_id   │   │ method       │
            │ date         │   │ created_at   │
            └──────────────┘   └──────────────┘
                    │
                    │
            ┌───────▼──────┐
            │   services   │
            ├──────────────┤
            │ id           │
            │ name         │
            │ description  │
            │ price        │
            │ duration     │
            └──────────────┘
```

### Tablas Principales

#### `users` - Usuarios del sistema
```sql
- id: bigint (PK)
- name: varchar
- email: varchar (unique)
- password: varchar (hashed con bcrypt)
- role: enum('admin', 'stylist', 'client')
- phone: varchar (nullable)
- avatar: varchar (nullable)
- is_active: boolean (default true)
- created_at, updated_at: timestamp
```

#### `clients` - Clientes de la peluquería
```sql
- id: bigint (PK)
- name: varchar
- phone: varchar
- email: varchar (nullable)
- created_at, updated_at: timestamp
```

#### `services` - Servicios ofrecidos
```sql
- id: bigint (PK)
- name: varchar
- description: text
- price: decimal(10,2)
- duration: integer (minutos)
- created_at, updated_at: timestamp
```

#### `appointments` - Citas agendadas
```sql
- id: bigint (PK)
- client_id: bigint (FK → clients)
- user_id: bigint (FK → users, estilista asignado)
- date: date
- time: time
- status: enum('pending', 'confirmed', 'completed', 'cancelled')
- notes: text (nullable)
- created_at, updated_at: timestamp
```

#### `attentions` - Atenciones realizadas
```sql
- id: bigint (PK)
- client_id: bigint (FK → clients)
- user_id: bigint (FK → users, estilista que atendió)
- service_id: bigint (FK → services)
- date: date
- time: time
- notes: text (nullable)
- created_at, updated_at: timestamp
```

#### `payments` - Pagos registrados
```sql
- id: bigint (PK)
- appointment_id: bigint (FK → appointments)
- amount: decimal(10,2)
- method: enum('cash', 'card', 'transfer')
- status: enum('pending', 'completed', 'cancelled')
- created_at, updated_at: timestamp
```

### Migraciones

Ejecutar migraciones:
```bash
# Local (MySQL)
php artisan migrate

# Producción (PostgreSQL en Railway)
railway run php artisan migrate --force
```

### Seeders

Datos de prueba:
```bash
php artisan db:seed
```

---

## 🔌 API Endpoints

Base URL: `https://pruebatek-production.up.railway.app/api`

### Autenticación

```http
POST /auth/register
POST /auth/login
POST /auth/logout
GET  /auth/me
```

**Ejemplo Login:**
```bash
curl -X POST https://pruebatek-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"anita@peluqueria.com","password":"admin123"}'
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Inicio de sesión exitoso",
  "data": {
    "user": {
      "id": 1,
      "name": "Anita Pérez",
      "email": "anita@peluqueria.com",
      "role": "admin"
    },
    "access_token": "1|token...",
    "token_type": "Bearer"
  }
}
```

### Clientes

```http
GET    /clients          # Listar todos
POST   /clients          # Crear nuevo
GET    /clients/{id}     # Ver uno
PUT    /clients/{id}     # Actualizar
DELETE /clients/{id}     # Eliminar
```

### Servicios

```http
GET    /services         # Listar todos
POST   /services         # Crear nuevo
GET    /services/{id}    # Ver uno
PUT    /services/{id}    # Actualizar
DELETE /services/{id}    # Eliminar
```

### Citas

```http
GET    /appointments           # Listar todas
POST   /appointments           # Crear nueva
GET    /appointments/{id}      # Ver una
PUT    /appointments/{id}      # Actualizar
DELETE /appointments/{id}      # Eliminar
PATCH  /appointments/{id}/status  # Cambiar estado
```

### Atenciones

```http
GET    /attentions        # Listar todas
POST   /attentions        # Registrar nueva
GET    /attentions/{id}   # Ver una
PUT    /attentions/{id}   # Actualizar
DELETE /attentions/{id}   # Eliminar
```

### Autenticación de Requests

Todas las rutas protegidas requieren token:
```bash
curl -H "Authorization: Bearer {token}" \
     -H "Accept: application/json" \
     https://pruebatek-production.up.railway.app/api/clients
```

---

## 💻 Desarrollo Local

### Requisitos Previos

- PHP 8.2+
- Composer
- MySQL 8.0+
- Node.js 18+ (para Angular)
- Flutter SDK 3.24+ (para Flutter)
- Git

### Setup Backend

1. **Clonar repositorio:**
```bash
git clone https://github.com/dgonzalez15/pruebaTEK.git
cd pruebaTEK/peluqueria-anita/backend-api
```

2. **Instalar dependencias:**
```bash
composer install
```

3. **Configurar `.env`:**
```bash
cp .env.example .env
php artisan key:generate
```

4. **Configurar base de datos local:**
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=peluqueria_anita
DB_USERNAME=root
DB_PASSWORD=
```

5. **Crear base de datos:**
```bash
mysql -u root -p
CREATE DATABASE peluqueria_anita;
exit;
```

6. **Ejecutar migraciones:**
```bash
php artisan migrate
php artisan db:seed
```

7. **Iniciar servidor:**
```bash
php artisan serve
# Disponible en http://localhost:8000
```

### Setup Frontend Flutter

1. **Ir al directorio:**
```bash
cd ../mobile-flutter
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Configurar URL API en `lib/utils/constants.dart`:**
```dart
static String get baseUrl {
  if (kIsWeb) {
    final uri = Uri.base;
    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      return 'http://localhost:8000/api';
    }
  }
  return 'https://pruebatek-production.up.railway.app/api';
}
```

4. **Ejecutar app:**
```bash
# Web
flutter run -d chrome

# Android
flutter run -d <device_id>
```

### Setup Frontend Angular (opcional)

1. **Ir al directorio:**
```bash
cd ../frontend-angular
```

2. **Instalar dependencias:**
```bash
npm install
# o
pnpm install
```

3. **Configurar environment:**
```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8000/api'
};
```

4. **Ejecutar:**
```bash
npm start
# o
ng serve
```

---

## 🔧 Troubleshooting

### Problema: Error de conexión a base de datos

**Síntoma:**
```
SQLSTATE[HY000] [2002] Connection refused
```

**Solución:**
1. Verificar que MySQL/PostgreSQL esté corriendo
2. Verificar credenciales en `.env`
3. Probar conexión:
```bash
# MySQL
mysql -u root -p -h 127.0.0.1

# PostgreSQL
psql "postgresql://user:password@host:port/database"
```

### Problema: CORS Error en Frontend

**Síntoma:**
```
Access to fetch at 'API_URL' has been blocked by CORS policy
```

**Solución:**
1. Verificar `config/cors.php` en backend:
```php
'allowed_origins' => ['*'], // o especificar dominios
'supports_credentials' => true,
```

2. Agregar dominio frontend a variables de entorno:
```env
FRONTEND_URL=https://tu-frontend.vercel.app
```

### Problema: Migraciones fallan en Railway

**Síntoma:**
```
Table 'railway.users' doesn't exist
```

**Solución:**
```bash
# Ejecutar migraciones manualmente
railway run php artisan migrate --force

# Verificar conexión a BD
railway run env | grep DATABASE_URL
```

### Problema: Backend no conecta a PostgreSQL

**Síntoma:**
```
could not translate host name "postgres.railway.internal"
```

**Solución:**
1. Usar URL pública de PostgreSQL
2. Actualizar variable en Railway:
```bash
railway variables --set "DATABASE_URL=postgresql://postgres:pass@host.rlwy.net:port/railway"
```

### Problema: Flutter no encuentra paquetes

**Síntoma:**
```
Error: Could not find package 'http'
```

**Solución:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

---

## 📚 Referencias y Documentación

### Laravel
- [Documentación Oficial](https://laravel.com/docs)
- [Laravel Sanctum](https://laravel.com/docs/sanctum)
- [Eloquent ORM](https://laravel.com/docs/eloquent)

### Flutter
- [Documentación Oficial](https://flutter.dev/docs)
- [Flutter Web](https://flutter.dev/web)
- [HTTP Package](https://pub.dev/packages/http)

### Railway
- [Documentación](https://docs.railway.app)
- [Railway CLI](https://docs.railway.app/develop/cli)

### Vercel
- [Documentación](https://vercel.com/docs)
- [Deploy Flutter](https://vercel.com/guides/deploying-flutter-with-vercel)

---

## 👥 Credenciales de Prueba

### Usuario Admin
```
Email: anita@peluqueria.com
Password: admin123
Rol: admin
```

### Usuario Estilista
```
Email: maria@peluqueria.com
Password: maria123
Rol: stylist
```

---

## 📝 Notas Importantes

1. **Nunca commitear** archivos `.env` con credenciales reales
2. **Siempre usar** migraciones para cambios en BD
3. **Probar localmente** antes de desplegar a producción
4. **Hacer backup** de BD antes de migraciones destructivas
5. **Revisar logs** en Railway cuando hay errores de deploy

---

## 🔄 Flujo de Trabajo Git

```bash
# 1. Crear rama feature
git checkout -b feature/nueva-funcionalidad

# 2. Hacer cambios y commits
git add .
git commit -m "feat: agregar nueva funcionalidad"

# 3. Push a GitHub
git push origin feature/nueva-funcionalidad

# 4. Crear Pull Request en GitHub

# 5. Merge a main (auto-deploy a Railway)
git checkout main
git merge feature/nueva-funcionalidad
git push origin main
```

---

## 📧 Contacto y Soporte

- **Desarrollador:** Diego González
- **Email:** diego_gonzalez15@live.com
- **Repositorio:** [github.com/dgonzalez15/pruebaTEK](https://github.com/dgonzalez15/pruebaTEK)

---

**Última actualización:** Octubre 2025
**Versión:** 1.0.0
