import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AppColors {
  // Colores principales
  static const Color primary = Color(0xFFE91E63); // Rosa principal
  static const Color secondary = Color(0xFF673AB7); // Púrpura
  static const Color accent = Color(0xFFFF5722); // Naranja
  
  // Colores de fondo
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFF999999);
  
  // Colores de estado
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF8F9FA)],
  );
}

class AppConstants {
  // API - Usa localhost para todas las plataformas (compatible con el servidor)
  static const String baseUrl = 'http://localhost:8001/api';
  static const String storageUrl = 'http://localhost:8000/storage';
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  
  // Pagination
  static const int defaultPageSize = 15;
  static const int maxPageSize = 50;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiTimeFormat = 'HH:mm:ss';
  static const String apiDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
}

class AppSizes {
  // Padding and margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Button heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
  
  // App bar height
  static const double appBarHeight = 56.0;
  
  // Bottom navigation height
  static const double bottomNavHeight = 80.0;
}

class AppStrings {
  // App
  static const String appName = 'Peluquería Anita';
  static const String appVersion = '1.0.0';
  
  // Authentication
  static const String login = 'Iniciar Sesión';
  static const String register = 'Registrarse';
  static const String logout = 'Cerrar Sesión';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String confirmPassword = 'Confirmar Contraseña';
  static const String forgotPassword = 'Olvidé mi contraseña';
  static const String rememberMe = 'Recordarme';
  
  // Navigation
  static const String home = 'Inicio';
  static const String appointments = 'Mis Citas';
  static const String services = 'Servicios';
  static const String profile = 'Perfil';
  static const String notifications = 'Notificaciones';
  
  // Appointments
  static const String newAppointment = 'Nueva Cita';
  static const String myAppointments = 'Mis Citas';
  static const String appointmentDate = 'Fecha de la Cita';
  static const String appointmentTime = 'Hora de la Cita';
  static const String selectService = 'Seleccionar Servicio';
  static const String bookAppointment = 'Reservar Cita';
  static const String cancelAppointment = 'Cancelar Cita';
  static const String rescheduleAppointment = 'Reprogramar Cita';
  
  // Status
  static const String pending = 'Pendiente';
  static const String confirmed = 'Confirmada';
  static const String completed = 'Completada';
  static const String cancelled = 'Cancelada';
  
  // Actions
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String view = 'Ver';
  static const String refresh = 'Actualizar';
  static const String retry = 'Reintentar';
  
  // Messages
  static const String loading = 'Cargando...';
  static const String noData = 'No hay datos disponibles';
  static const String errorOccurred = 'Ha ocurrido un error';
  static const String tryAgain = 'Intentar de nuevo';
  static const String success = 'Éxito';
  static const String error = 'Error';
  static const String warning = 'Advertencia';
  static const String info = 'Información';
  
  // Validation
  static const String fieldRequired = 'Este campo es obligatorio';
  static const String invalidEmail = 'Correo electrónico inválido';
  static const String passwordTooShort = 'La contraseña debe tener al menos 6 caracteres';
  static const String passwordsDontMatch = 'Las contraseñas no coinciden';
  static const String invalidPhone = 'Número de teléfono inválido';
}

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String appointments = '/appointments';
  static const String newAppointment = '/new-appointment';
  static const String services = '/services';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}