import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Agregar interceptor para manejo de errores y logs
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Agregar token si existe
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        print('Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode} ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('Error: ${error.message}');
        handler.next(error);
      },
    ));

    // Cargar token guardado
    await _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;

  // Métodos HTTP genéricos
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 500,
        data: {'success': false, 'message': 'Error de conexión (GET $endpoint)'},
      );
    }
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 500,
        data: {'success': false, 'message': 'Error de conexión (POST $endpoint)'},
      );
    }
  }

  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 500,
        data: {'success': false, 'message': 'Error de conexión (PUT $endpoint)'},
      );
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 500,
        data: {'success': false, 'message': 'Error de conexión (DELETE $endpoint)'},
      );
    }
  }

  // Métodos específicos de la API
  
  // Autenticación
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['data']['access_token'];
        await setToken(token);
        return response.data;
      }
      
      // Retornar el error sin lanzar excepción
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al iniciar sesión'
      };
    } catch (e) {
      print('🚨 Error en ApiService.login: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Verifica que el servidor esté funcionando.'
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await post('/auth/register', data: userData);
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data;
      }
      
      // Retornar el error sin lanzar excepción
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al registrarse'
      };
    } catch (e) {
      print('🚨 Error en ApiService.register: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Verifica que el servidor esté funcionando.'
      };
    }
  }

  Future<void> logout() async {
    try {
      await post('/logout');
    } catch (e) {
      // Ignorar errores del logout en el servidor
    } finally {
      await clearToken();
    }
  }

  // Usuario
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('ApiService: Obteniendo usuario actual...');
      
      final response = await get('/user');
      print('ApiService: Respuesta usuario - Status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al obtener usuario',
      };
    } catch (e) {
      print('ApiService: Error obteniendo usuario: $e');
      return {
        'success': false,
        'message': 'Error de conexión al obtener usuario',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    try {
      print('ApiService: Actualizando perfil...');
      
      final response = await put('/user/profile', data: userData);
      print('ApiService: Respuesta actualizar perfil - Status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al actualizar perfil',
      };
    } catch (e) {
      print('ApiService: Error actualizando perfil: $e');
      return {
        'success': false,
        'message': 'Error de conexión al actualizar perfil',
      };
    }
  }

  // Servicios
  Future<Map<String, dynamic>> getServices() async {
    try {
      print('ApiService: Obteniendo servicios...');
      
      final response = await get('/services');
      print('ApiService: Respuesta servicios - Status: ${response.statusCode}');
      print('ApiService: Respuesta servicios - Data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al obtener servicios',
      };
    } catch (e) {
      print('ApiService: Error obteniendo servicios: $e');
      return {
        'success': false,
        'message': 'Error de conexión al obtener servicios',
      };
    }
  }

  // Citas
  Future<Map<String, dynamic>> getAppointments({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    try {
      print('ApiService: Obteniendo citas...');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await get('/appointments', queryParameters: queryParams);
      print('ApiService: Respuesta citas - Status: ${response.statusCode}');
      print('ApiService: Respuesta citas - Data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al obtener citas',
      };
    } catch (e) {
      print('ApiService: Error obteniendo citas: $e');
      return {
        'success': false,
        'message': 'Error de conexión al obtener citas',
      };
    }
  }

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      print('ApiService: Creando cita...');
      
      final response = await post('/appointments', data: appointmentData);
      print('ApiService: Respuesta crear cita - Status: ${response.statusCode}');
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al crear cita',
      };
    } catch (e) {
      print('ApiService: Error creando cita: $e');
      return {
        'success': false,
        'message': 'Error de conexión al crear cita',
      };
    }
  }

  Future<Map<String, dynamic>> updateAppointment(int id, Map<String, dynamic> appointmentData) async {
    try {
      print('ApiService: Actualizando cita...');
      
      final response = await put('/appointments/$id', data: appointmentData);
      print('ApiService: Respuesta actualizar cita - Status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al actualizar cita',
      };
    } catch (e) {
      print('ApiService: Error actualizando cita: $e');
      return {
        'success': false,
        'message': 'Error de conexión al actualizar cita',
      };
    }
  }

  Future<Map<String, dynamic>> cancelAppointment(int id) async {
    try {
      print('ApiService: Cancelando cita...');
      
      final response = await put('/appointments/$id', data: {'status': 'cancelled'});
      print('ApiService: Respuesta cancelar cita - Status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al cancelar cita',
      };
    } catch (e) {
      print('ApiService: Error cancelando cita: $e');
      return {
        'success': false,
        'message': 'Error de conexión al cancelar cita',
      };
    }
  }

  // Estadísticas del dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('ApiService: Obteniendo estadísticas del dashboard...');
      
      final response = await get('/dashboard/stats');
      print('ApiService: Respuesta estadísticas - Status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al obtener estadísticas',
      };
    } catch (e) {
      print('ApiService: Error obteniendo estadísticas: $e');
      return {
        'success': false,
        'message': 'Error de conexión al obtener estadísticas',
      };
    }
  }
}