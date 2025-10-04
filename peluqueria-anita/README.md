# 💇‍♀️ Sistema de Gestión Peluquería Anita

Un sistema completo de gestión para peluquerías que incluye control de citas, gestión de clientes y administración de servicios.

## 🏗️ Arquitectura del Sistema

Este proyecto está construido con una arquitectura moderna de microservicios que incluye:

- **Backend API**: Laravel 10.x (PHP 8.2+)
- **Frontend Web**: Angular 17.x
- **Aplicación Móvil**: Flutter 3.x
- **Base de Datos**: MySQL 8.0+
- **Despliegue**: Docker, Heroku/Vercel

## 📁 Estructura del Proyecto

```
peluqueria-anita/
├── backend-api/          # API RESTful en Laravel
├── frontend-angular/     # Aplicación web en Angular
├── mobile-flutter/       # Aplicación móvil en Flutter
├── database/            # Scripts y modelos de base de datos
├── docs/               # Documentación técnica
└── docker-compose.yml  # Configuración de contenedores
```

## 🚀 Inicio Rápido

### Prerrequisitos

- PHP 8.2+
- Node.js 18+
- Flutter 3.x
- MySQL 8.0+
- Composer
- Docker (opcional)

### Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/peluqueria-anita.git
cd peluqueria-anita
```

2. **Configurar Backend (Laravel)**
```bash
cd backend-api
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

3. **Configurar Frontend (Angular)**
```bash
cd frontend-angular
npm install
ng serve
```

4. **Configurar Móvil (Flutter)**
```bash
cd mobile-flutter
flutter pub get
flutter run
```

## 📊 Modelo de Base de Datos

### Entidades Principales

- **Users** (Usuarios del sistema)
- **Clients** (Clientes de la peluquería)
- **Services** (Servicios ofrecidos)
- **Appointments** (Citas - Cabecera)
- **Appointment_Details** (Detalles de citas - Detalle)
- **Payments** (Pagos)

### Relaciones

- Un cliente puede tener múltiples citas
- Una cita puede incluir múltiples servicios
- Cada cita tiene un estado (pendiente, confirmada, completada, cancelada)

## 🔐 Autenticación y Autorización

- Sistema de login con JWT
- Roles: Admin, Estilista, Cliente
- Registro de nuevos usuarios
- Recuperación de contraseña

## 📱 Funcionalidades

### Web (Angular)
- ✅ Dashboard administrativo
- ✅ Gestión de citas
- ✅ Gestión de clientes
- ✅ Gestión de servicios
- ✅ Reportes y estadísticas

### Móvil (Flutter)
- ✅ Agendar citas
- ✅ Ver historial de citas
- ✅ Perfil de cliente
- ✅ Notificaciones

## 🎨 Tecnologías Utilizadas

| Categoría | Tecnología | Versión |
|-----------|------------|---------|
| Backend | Laravel | 10.x |
| Frontend | Angular | 17.x |
| Móvil | Flutter | 3.x |
| Base de Datos | MySQL | 8.0+ |
| Autenticación | JWT | - |
| CSS Framework | Bootstrap | 5.x |
| Contenedores | Docker | - |

## 🚀 Despliegue

### Desarrollo Local
Cada aplicación incluye instrucciones específicas en su directorio respectivo.

### Producción
- **API**: Heroku o AWS
- **Frontend**: Vercel o Netlify
- **Base de Datos**: PlanetScale o AWS RDS
- **Móvil**: Google Play Store / App Store

## 📚 Documentación

- [Documentación de la API](./docs/api-documentation.md)
- [Guía de instalación](./docs/installation-guide.md)
- [Modelo de datos](./docs/database-model.md)
- [Guía de contribución](./docs/contributing.md)

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📞 Soporte

Para soporte técnico o consultas:
- Email: soporte@peluqueriaanita.com
- Issues: [GitHub Issues](https://github.com/tu-usuario/peluqueria-anita/issues)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

---

⭐ **¿Te gusta el proyecto? ¡Dale una estrella!**