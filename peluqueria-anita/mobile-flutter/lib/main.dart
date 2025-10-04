import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/service_provider.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/appointments/appointments_screen.dart';
import 'screens/appointments/new_appointment_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'utils/constants.dart';

void main() async {
  // Asegurar que Flutter esté inicializado antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización para español
  await initializeDateFormatting('es', null);

  // Inicializar ApiService
  await ApiService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final router = GoRouter(
            initialLocation: '/splash',
            refreshListenable: authProvider,
            redirect: (context, state) {
              final isLoggedIn = authProvider.isLoggedIn;
              final isInitialized = authProvider.isInitialized;
              final currentLocation = state.matchedLocation;

              print('🗺️ GoRouter redirect - Location: $currentLocation, Initialized: $isInitialized, LoggedIn: $isLoggedIn');

              // Si no está inicializado, mantener en splash
              if (!isInitialized) {
                if (currentLocation != '/splash') {
                  print('🔄 Redirigiendo a splash - no inicializado');
                  return '/splash';
                }
                return null;
              }

              // Si está en splash y ya está inicializado, redirigir según estado
              if (currentLocation == '/splash') {
                final destination = isLoggedIn ? '/home' : '/login';
                print('🔄 Redirigiendo desde splash a: $destination');
                return destination;
              }

              // Si no está logueado y trata de acceder a rutas protegidas
              if (!isLoggedIn && 
                  !currentLocation.startsWith('/login') && 
                  !currentLocation.startsWith('/register') &&
                  currentLocation != '/splash') {
                print('🔄 Redirigiendo a login - no autenticado');
                return '/login';
              }

              // Si está logueado y trata de acceder a login/register
              if (isLoggedIn && 
                  (currentLocation.startsWith('/login') || currentLocation.startsWith('/register'))) {
                print('🔄 Redirigiendo a home - ya autenticado');
                return '/home';
              }

              return null;
            },
            routes: [
              GoRoute(
                path: '/splash',
                builder: (context, state) => const SplashScreen(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginScreen(),
              ),
              GoRoute(
                path: '/register',
                builder: (context, state) => const RegisterScreen(),
              ),
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/appointments',
                builder: (context, state) => const AppointmentsScreen(),
              ),
              GoRoute(
                path: '/new-appointment',
                builder: (context, state) => const NewAppointmentScreen(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          );

          return MaterialApp.router(
            title: 'Peluquería Anita',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.pink,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              textTheme: const TextTheme(
                headlineLarge: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.bold),
                headlineMedium: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w600),
                bodyLarge: TextStyle(fontFamily: 'SF Pro Text'),
                bodyMedium: TextStyle(fontFamily: 'SF Pro Text'),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}