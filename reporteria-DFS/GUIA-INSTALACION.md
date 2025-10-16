# 🚀 Guía de Instalación y Ejecución - Reportería DFS

Sistema de reportería completo con backend Laravel y frontend Angular 18.

## 📋 Requisitos Previos

### Backend
- PHP 8.2 o superior
- Composer
- PostgreSQL 12+ o MySQL 8.0+ (recomendado PostgreSQL)

### Frontend
- Node.js 18+ y npm
- Angular CLI 18

---

## 🔧 Instalación Rápida

### Paso 1: Clonar y preparar el backend

```bash
cd reporteria-peluqueria/backend-api

# Instalar dependencias
composer install

# Copiar archivo de entorno
cp .env.example .env

# Generar key de aplicación
php artisan key:generate
```

### Paso 2: Configurar Base de Datos

El proyecto soporta **PostgreSQL** (recomendado) y **MySQL**.

#### Opción A: Usar script automático (recomendado)

```bash
./setup-database.sh
```

El script detectará qué base de datos tienes instalada y te guiará en la configuración.

#### Opción B: Configuración manual

##### PostgreSQL (recomendado)

1. Crear la base de datos:
```bash
psql -U postgres
CREATE DATABASE reporteria_dfs ENCODING 'UTF8';
\q
```

2. Editar `.env`:
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=reporteria_dfs
DB_USERNAME=postgres
DB_PASSWORD=tu_password
```

3. Ejecutar migraciones:
```bash
php artisan migrate:fresh --seed
```

##### MySQL

1. Crear la base de datos:
```bash
mysql -u root -p
CREATE DATABASE reporteria_dfs CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

2. Editar `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=reporteria_dfs
DB_USERNAME=root
DB_PASSWORD=tu_password
```

3. Ejecutar migraciones:
```bash
php artisan migrate:fresh --seed
```

### Paso 3: Instalar Frontend

```bash
cd ../frontend
npm install
```

---

## 🎯 Ejecución

### Opción 1: Script Automático (Recomendado)

Desde la raíz del proyecto `pruebaTEK/`:

```bash
./start-all.sh
```

Esto levanta:
- Backend en `http://127.0.0.1:8000`
- Frontend en `http://localhost:4200`

Los logs se guardan en `logs/backend.log` y `logs/frontend.log`.

**Ver logs en tiempo real:**
```bash
tail -f logs/backend.log logs/frontend.log
```

**Detener servicios:**
```bash
./stop-all.sh
```

O presiona `Ctrl+C` en la terminal donde ejecutaste `start-all.sh`.

### Opción 2: Ejecución Manual

**Terminal 1 - Backend:**
```bash
cd reporteria-peluqueria/backend-api
php artisan serve --host=127.0.0.1 --port=8000
```

**Terminal 2 - Frontend:**
```bash
cd reporteria-peluqueria/frontend
npm start
# o: ng serve
```

---

## 🔐 Credenciales de Prueba

Después de ejecutar los seeders, puedes usar:

- **Email:** `admin@dfs.com`
- **Password:** `password123`
- **Rol:** Administrador

Usuarios adicionales:
- `maria@dfs.com` - Estilista (password: password123)
- `carlos@dfs.com` - Estilista (password: password123)

---

## 📊 Endpoints de la API

### Autenticación

**Login:**
```bash
POST http://127.0.0.1:8000/api/auth/login
Content-Type: application/json

{
  "email": "admin@dfs.com",
  "password": "password123"
}
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "access_token": "token_aqui",
    "token_type": "Bearer",
    "user": {
      "id": 1,
      "name": "Admin DFS",
      "email": "admin@dfs.com",
      "role": "admin"
    }
  }
}
```

### Reportes (requieren autenticación)

Incluye el token en los headers:
```
Authorization: Bearer {tu_token}
```

**Reporte A - Personas por Cita:**
```bash
GET http://127.0.0.1:8000/api/reports/personas-por-cita?start_date=2025-01-01&end_date=2025-12-31
```

**Reporte B - Personas, Atenciones y Servicios:**
```bash
GET http://127.0.0.1:8000/api/reports/personas-atenciones-servicios?start_date=2025-01-01&end_date=2025-12-31
```

**Reporte C - Citas y Ventas por Persona:**
```bash
GET http://127.0.0.1:8000/api/reports/citas-ventas?start_date=2025-01-01&end_date=2025-12-31
```

**Reporte D - Citas y Atenciones:**
```bash
GET http://127.0.0.1:8000/api/reports/citas-atenciones?start_date=2025-01-01&end_date=2025-12-31&status=completed
```

**Reporte Consolidado (Dashboard):**
```bash
GET http://127.0.0.1:8000/api/reports/consolidado?start_date=2025-01-01&end_date=2025-12-31
```

**Exportar a CSV:**
```bash
GET http://127.0.0.1:8000/api/reports/export?tipo=A&start_date=2025-01-01&end_date=2025-12-31
```
Valores de `tipo`: `A`, `B`, `C`, `D`

---

## 🧪 Pruebas Rápidas

### 1. Health Check
```bash
curl http://127.0.0.1:8000/api/health
```

Respuesta esperada:
```json
{"status":"ok","timestamp":"2025-10-16T..."}
```

### 2. Login y obtener token
```bash
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@dfs.com","password":"password123"}' | jq .
```

### 3. Probar reporte consolidado
```bash
TOKEN="tu_token_aqui"

curl http://127.0.0.1:8000/api/reports/consolidado \
  -H "Authorization: Bearer $TOKEN" | jq .
```

---

## 🐛 Solución de Problemas

### Backend no inicia

**Error: "Connection refused" o problemas de BD**
- Verifica que PostgreSQL/MySQL esté corriendo:
  ```bash
  # PostgreSQL
  pg_isready
  
  # MySQL
  mysqladmin ping
  ```
- Revisa las credenciales en `.env`
- Ejecuta migraciones de nuevo: `php artisan migrate:fresh --seed`

**Error: "Address already in use" (puerto 8000)**
- Encuentra el proceso:
  ```bash
  lsof -nP -iTCP:8000 -sTCP:LISTEN
  ```
- Mata el proceso:
  ```bash
  kill -9 <PID>
  ```

### Frontend no inicia

**Error: "Port 4200 is already in use"**
- Encuentra el proceso:
  ```bash
  lsof -nP -iTCP:4200 -sTCP:LISTEN
  ```
- Mata el proceso:
  ```bash
  kill -9 <PID>
  ```
- O usa un puerto diferente:
  ```bash
  ng serve --port 4201
  ```

### CORS errors en el navegador

El backend ya tiene CORS configurado para desarrollo. Si aún ves errores:
- Verifica que el frontend esté usando `http://localhost:8000/api` en `environment.ts`
- Revisa `backend-api/config/cors.php`

---

## 📁 Estructura del Proyecto

```
reporteria-peluqueria/
├── backend-api/           # Laravel API
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   │   ├── AuthController.php
│   │   │   └── ReportController.php
│   │   └── Models/
│   │       ├── Person.php
│   │       ├── Cite.php
│   │       ├── Attention.php
│   │       └── Service.php
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── routes/api.php
│   └── setup-database.sh  # Script de setup
│
└── frontend/              # Angular 18
    ├── src/
    │   ├── app/
    │   │   ├── services/
    │   │   │   ├── auth.service.ts
    │   │   │   └── report.service.ts
    │   │   └── pages/
    │   │       ├── login/
    │   │       └── dashboard/
    │   └── environments/
    └── package.json
```

---

## 📖 Documentación Adicional

- Modelos y relaciones: `docs/database-model.md`
- API completa: `backend-api/API-DOCUMENTATION.md`
- Guía de despliegue: `DEPLOYMENT.md`

---

## 🤝 Soporte

Para problemas o preguntas:
1. Revisa los logs: `tail -f logs/backend.log logs/frontend.log`
2. Verifica la configuración de `.env`
3. Ejecuta `php artisan config:clear && php artisan cache:clear`

---

**¡Listo! Tu sistema de Reportería DFS está corriendo.** 🎉

Accede a `http://localhost:4200` y usa las credenciales de prueba para explorar los reportes.
