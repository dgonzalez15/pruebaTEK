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
  // API - Configuración dinámica según entorno
  static String get baseUrl {
    // En producción (web desplegado), usa la URL del backend en producción
    const String productionUrl = String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://tu-backend-api.railway.app/api', // Cambiar cuando despliegues el backend
    );
    
    if (kIsWeb) {
      // En web, verifica si estamos en localhost (desarrollo) o en producción
      final currentUrl = Uri.base.toString();
      if (currentUrl.contains('localhost') || currentUrl.contains('127.0.0.1')) {
        return 'http://localhost:8001/api'; // Desarrollo local
      }
      return productionUrl; // Producción
    } else if (defaultTargetPlatform == TargetPlatform.iOS || 
               defaultTargetPlatform == TargetPlatform.macOS) {
      // En iOS/macOS nativos
      return 'http://localhost:8001/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // En Android emulador
      return 'http://10.0.2.2:8001/api';
    }
    // Por defecto
    return 'http://localhost:8001/api';
  }
  
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
  
  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String appointmentsRoute = '/appointments';
  static const String newAppointmentRoute = '/new-appointment';
  static const String servicesRoute = '/services';
  static const String settingsRoute = '/settings';
}

class AppSizes {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  
  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Button sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  
  // Container sizes
  static const double maxContentWidth = 1200.0;
  static const double cardMaxWidth = 400.0;
}

class AppStrings {
  // App
  static const String appName = 'Peluquería Anita';
  static const String appVersion = '1.0.0';
  
  // Auth
  static const String login = 'Iniciar Sesión';
  static const String register = 'Registrarse';
  static const String logout = 'Cerrar Sesión';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String confirmPassword = 'Confirmar Contraseña';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String rememberMe = 'Recordarme';
  
  // Navigation
  static const String home = 'Inicio';
  static const String appointments = 'Mis Citas';
  static const String services = 'Servicios';
  static const String profile = 'Perfil';
  
  // Common
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String search = 'Buscar';
  static const String filter = 'Filtrar';
  static const String loading = 'Cargando...';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String warning = 'Advertencia';
  static const String info = 'Información';
}

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pendiente';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
    }
  }
  
  Color get color {
    switch (this) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.info;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
    }
  }
  
  static AppointmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }
}
