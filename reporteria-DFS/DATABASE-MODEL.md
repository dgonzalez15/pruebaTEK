# Sistema de Reportería DFS - Backend API

## Modelo de Base de Datos

El sistema utiliza el siguiente esquema de base de datos según la imagen proporcionada:

### Tablas Principales

#### 1. **person**
Almacena información de las personas/clientes.
```
- id (PK)
- document (VARCHAR, UNIQUE)
- first_name (VARCHAR)
- last_name (VARCHAR)
- address (TEXT, nullable)
- phone (VARCHAR)
- email (VARCHAR, UNIQUE)
- timestamps
```

#### 2. **Cite**
Gestiona las citas programadas.
```
- id (PK)
- date (DATE)
- cliente_id (FK → person.id)
- amount_attention (DECIMAL)
- time_arrival (TIME, nullable)
- total_service (DECIMAL)
- status (ENUM: scheduled, confirmed, completed, cancelled)
- timestamps
```

#### 3. **attention**
Registra los servicios realizados en cada cita.
```
- id (PK)
- date (DATE)
- cite_id (FK → Cite.id)
- service_id (FK → service.id)
- price_service (DECIMAL)
- timestamps
```

#### 4. **service**
Catálogo de servicios disponibles.
```
- id (PK)
- name (VARCHAR)
- slug (VARCHAR, UNIQUE)
- timestamps
```

#### 5. **price_service**
Precios históricos y actuales de los servicios.
```
- id (PK)
- value (DECIMAL)
- status (BOOLEAN)
- service_id (FK → service.id)
- timestamps
```

#### 6. **User**
Usuarios del sistema (administradores).
```
- id (PK)
- user_name (VARCHAR, UNIQUE)
- first_name (VARCHAR)
- last_name (VARCHAR)
- password (VARCHAR, hashed)
- email (VARCHAR, UNIQUE)
- remember_token
- timestamps
```

#### 7. **log**
Registro de auditoría del sistema.
```
- id (PK)
- entity (VARCHAR)
- date (DATE)
- description (TEXT)
- timestamps
```

## Relaciones del Modelo

- **Person → Cite**: Una persona puede tener múltiples citas (1:N)
- **Cite → Attention**: Una cita puede tener múltiples atenciones/servicios (1:N)
- **Service → Attention**: Un servicio puede estar en múltiples atenciones (1:N)
- **Service → PriceService**: Un servicio puede tener múltiples precios (histórico) (1:N)

## Instalación

1. Instalar dependencias:
```bash
composer install
```

2. Configurar entorno:
```bash
cp .env.example .env
php artisan key:generate
```

3. Configurar base de datos en `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=reporteria_dfs
DB_USERNAME=root
DB_PASSWORD=
```

4. Ejecutar migraciones:
```bash
php artisan migrate
```

5. Ejecutar seeders (opcional):
```bash
php artisan db:seed
```

## Endpoints de la API

### Autenticación

#### POST `/api/login`
Iniciar sesión y obtener token.
```json
{
  "email": "admin@dfs.com",
  "password": "password123"
}
```

#### POST `/api/logout`
Cerrar sesión (requiere autenticación).

### Reportes (requieren autenticación)

#### GET `/api/reports/personas-por-cita`
Reporte A: Listado de personas por cita.

Parámetros opcionales:
- `start_date` (YYYY-MM-DD)
- `end_date` (YYYY-MM-DD)
- `status` (scheduled, confirmed, completed, cancelled)

#### GET `/api/reports/personas-atenciones-servicios`
Reporte B: Personas con atenciones y servicios.

Parámetros opcionales:
- `start_date` (YYYY-MM-DD)
- `end_date` (YYYY-MM-DD)

#### GET `/api/reports/citas-ventas`
Reporte C: Citas y ventas por persona.

Parámetros opcionales:
- `start_date` (YYYY-MM-DD)
- `end_date` (YYYY-MM-DD)

#### GET `/api/reports/citas-atenciones`
Reporte D: Citas y atenciones detalladas.

Parámetros opcionales:
- `start_date` (YYYY-MM-DD)
- `end_date` (YYYY-MM-DD)
- `status` (scheduled, confirmed, completed, cancelled)

#### GET `/api/reports/consolidado`
Dashboard con métricas consolidadas.

Parámetros opcionales:
- `start_date` (YYYY-MM-DD)
- `end_date` (YYYY-MM-DD)

#### GET `/api/reports/export`
Exportar reporte a CSV.

Parámetros requeridos:
- `tipo` (A, B, C, D)

Parámetros opcionales:
- `start_date` (YYYY-MM-DD)
- `end_date` (YYYY-MM-DD)

## Autenticación

El sistema utiliza **Laravel Sanctum** para la autenticación basada en tokens.

Para acceder a las rutas protegidas:
1. Realizar login en `/api/login`
2. Obtener el token del response
3. Incluir el token en el header: `Authorization: Bearer {token}`

## Datos de Prueba

Usuario por defecto (creado con el seeder):
- **Email**: admin@dfs.com
- **Password**: password123

## Tecnologías

- **Laravel 12**
- **PHP 8.2+**
- **MySQL 8.0+**
- **Laravel Sanctum 4.2**
