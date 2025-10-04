# 🚀 Backend API - Peluquería Anita

API RESTful desarrollada con Laravel 11 para el sistema de gestión de la Peluquería Anita.

## 🛠️ Tecnologías Utilizadas

- **Laravel**: 11.x
- **PHP**: 8.2+
- **Base de Datos**: SQLite (desarrollo) / MySQL (producción)
- **Autenticación**: Laravel Sanctum (JWT)
- **API**: RESTful con JSON

## 📁 Estructura del Proyecto

```
backend-api/
├── app/
│   ├── Http/Controllers/Api/     # Controladores de la API
│   └── Models/                   # Modelos Eloquent
├── database/
│   ├── migrations/               # Migraciones de base de datos
│   └── seeders/                  # Datos de prueba
├── routes/
│   └── api.php                   # Rutas de la API
└── config/                       # Configuraciones
```

## 🚀 Instalación y Configuración

### 1. Instalar Dependencias

```bash
composer install
```

### 2. Configurar Variables de Entorno

```bash
cp .env.example .env
php artisan key:generate
```

### 3. Configurar Base de Datos

Edita el archivo `.env` con tu configuración de base de datos:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=peluqueria_anita
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password
```

### 4. Ejecutar Migraciones y Seeders

```bash
php artisan migrate --seed
```

### 5. Iniciar Servidor de Desarrollo

```bash
php artisan serve
```

La API estará disponible en: `http://localhost:8000`

## 📊 Modelos y Relaciones

### Usuarios (Users)
- **Campos**: id, name, email, password, role, phone, avatar, is_active
- **Roles**: admin, stylist, client
- **Relaciones**: hasMany(Appointments)

### Clientes (Clients)
- **Campos**: id, name, email, phone, address, birth_date, gender, notes, is_active
- **Relaciones**: hasMany(Appointments)

### Servicios (Services)
- **Campos**: id, name, description, duration, price, category, is_active
- **Relaciones**: belongsToMany(Appointments)

### Citas (Appointments) - Cabecera
- **Campos**: id, client_id, user_id, appointment_date, start_time, end_time, status, total_amount, notes
- **Estados**: pending, confirmed, in_progress, completed, cancelled, no_show
- **Relaciones**: 
  - belongsTo(Client, User)
  - hasMany(AppointmentDetails, Payments)

### Detalles de Citas (AppointmentDetails) - Detalle
- **Campos**: id, appointment_id, service_id, quantity, unit_price, subtotal
- **Relaciones**: belongsTo(Appointment, Service)

### Pagos (Payments)
- **Campos**: id, appointment_id, amount, payment_method, payment_date, status, transaction_id, notes
- **Métodos**: cash, card, transfer, digital
- **Relaciones**: belongsTo(Appointment)

## 🔐 Autenticación

La API utiliza Laravel Sanctum para autenticación basada en tokens.

### Registro
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "Juan Pérez",
  "email": "juan@email.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "555-0123",
  "role": "client"
}
```

### Inicio de Sesión
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "anita@peluqueria.com",
  "password": "password123"
}
```

### Usar Token en Requests
```http
Authorization: Bearer {token}
```

## 📡 Endpoints de la API

### Autenticación
- `POST /api/auth/register` - Registro de usuario
- `POST /api/auth/login` - Inicio de sesión
- `POST /api/auth/logout` - Cerrar sesión
- `GET /api/auth/user` - Información del usuario autenticado
- `PUT /api/auth/profile` - Actualizar perfil

### Clientes
- `GET /api/clients` - Listar clientes
- `POST /api/clients` - Crear cliente
- `GET /api/clients/{id}` - Obtener cliente
- `PUT /api/clients/{id}` - Actualizar cliente
- `DELETE /api/clients/{id}` - Eliminar cliente

### Servicios
- `GET /api/services` - Listar servicios
- `POST /api/services` - Crear servicio
- `GET /api/services/{id}` - Obtener servicio
- `PUT /api/services/{id}` - Actualizar servicio
- `DELETE /api/services/{id}` - Eliminar servicio

### Citas
- `GET /api/appointments` - Listar citas
- `POST /api/appointments` - Crear cita
- `GET /api/appointments/{id}` - Obtener cita
- `PUT /api/appointments/{id}` - Actualizar cita
- `DELETE /api/appointments/{id}` - Eliminar cita
- `GET /api/appointments/today` - Citas del día
- `GET /api/appointments/by-stylist/{stylistId}` - Citas por estilista
- `PATCH /api/appointments/{id}/status` - Cambiar estado de cita

### Pagos
- `GET /api/payments` - Listar pagos
- `POST /api/payments` - Crear pago
- `GET /api/payments/{id}` - Obtener pago
- `PUT /api/payments/{id}` - Actualizar pago
- `DELETE /api/payments/{id}` - Eliminar pago

### Dashboard
- `GET /api/dashboard/stats` - Estadísticas generales
- `GET /api/dashboard/revenue` - Ingresos
- `GET /api/dashboard/appointments-calendar` - Calendario de citas

### Utilidades
- `GET /api/health` - Estado de la API

## 👥 Usuarios de Prueba

La base de datos incluye usuarios de prueba:

| Rol | Email | Contraseña | Descripción |
|-----|-------|------------|-------------|
| Admin | anita@peluqueria.com | password123 | Administradora |
| Stylist | maria@peluqueria.com | password123 | Estilista 1 |
| Stylist | carlos@peluqueria.com | password123 | Estilista 2 |

## 🛡️ Seguridad

- Autenticación con tokens seguros
- Validación de datos en todos los endpoints
- Middleware de autorización por roles
- Sanitización de entradas
- CORS configurado para frontend

## 🧪 Testing

```bash
# Ejecutar tests
php artisan test

# Ejecutar con cobertura
php artisan test --coverage
```

## 📝 Logs

Los logs se almacenan en:
- `storage/logs/laravel.log`

Para ver logs en tiempo real:
```bash
tail -f storage/logs/laravel.log
```

## 🚀 Despliegue

### Producción con MySQL

1. Configurar base de datos MySQL
2. Actualizar variables de entorno
3. Ejecutar migraciones:
```bash
php artisan migrate --force
```

### Optimizaciones para Producción

```bash
# Optimizar autoloader
composer install --optimize-autoloader --no-dev

# Cachear configuración
php artisan config:cache

# Cachear rutas
php artisan route:cache

# Cachear vistas
php artisan view:cache
```

## 🤝 Contribución

1. Fork del proyecto
2. Crear rama feature: `git checkout -b feature/nueva-funcionalidad`
3. Commit: `git commit -m 'Agregar nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework.

You may also try the [Laravel Bootcamp](https://bootcamp.laravel.com), where you will be guided through building a modern Laravel application from scratch.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com)**
- **[Tighten Co.](https://tighten.co)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Redberry](https://redberry.international/laravel-development)**
- **[Active Logic](https://activelogic.com)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
