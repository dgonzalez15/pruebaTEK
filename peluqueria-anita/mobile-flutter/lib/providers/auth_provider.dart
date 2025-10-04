import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    print('🚀 Iniciando AuthProvider...');
    _setLoading(true);
    
    try {
      // Verificar si hay un token guardado
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userData = prefs.getString(AppConstants.userKey);
      
      print('🔍 Token guardado: ${token != null ? "Sí" : "No"}');
      print('🔍 Datos de usuario guardados: ${userData != null ? "Sí" : "No"}');
      
      if (token != null && userData != null) {
        // Restaurar sesión
        try {
          print('🔄 Restaurando sesión...');
          _user = User.fromJson(jsonDecode(userData));
          await _apiService.setToken(token);
          
          // Verificar que el token siga siendo válido con timeout
          final result = await getCurrentUser().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⏰ Timeout verificando token');
              return false;
            },
          );
          
          if (result) {
            _isLoggedIn = true;
            print('✅ Sesión restaurada exitosamente');
          } else {
            print('❌ Token inválido, limpiando sesión');
            await logout();
          }
        } catch (e) {
          print('🚨 Error restaurando sesión: $e');
          // Token inválido, limpiar datos
          await logout();
        }
      } else {
        print('ℹ️ No hay sesión previa');
      }
    } catch (e) {
      print('🚨 Error inicializando AuthProvider: $e');
    } finally {
      _isInitialized = true;
      _setLoading(false);
      print('✅ AuthProvider inicializado');
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔄 Iniciando login para: $email');
      print('🌐 URL API: ${AppConstants.baseUrl}');

      final result = await _apiService.login(email, password);
      
      print('📝 Respuesta del servidor: $result');
      
      if (result['success'] == true) {
        print('✅ Login exitoso');
        
        // Guardar datos del usuario
        final userData = result['data']['user'];
        _user = User.fromJson(userData);
        
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, jsonEncode(userData));
        
        _isLoggedIn = true;
        print('✅ Usuario logueado: ${_user!.name}');
        return true;
      } else {
        print('❌ Login fallido: ${result['message']}');
        _setError(result['message'] ?? 'Credenciales inválidas');
        return false;
      }
    } catch (e) {
      print('🚨 Error en login: $e');
      _setError('Error de conexión. Verifica que el servidor esté funcionando.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.register({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
        'role': 'client', // Los registros desde móvil son siempre clientes
      });
      
      if (response['success'] == true) {
        // Después del registro exitoso, hacer login automático
        return await login(email, password);
      }
      
      _setError(response['message'] ?? 'Error al registrarse');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _user = null;
      _isLoggedIn = false;
      _setError(null);
      _setLoading(false);
    }
  }

  Future<bool> getCurrentUser() async {
    if (!_apiService.hasToken) return false;
    
    try {
      print('🔄 Obteniendo usuario actual...');
      final response = await _apiService.getCurrentUser();
      
      if (response['success'] == true) {
        final userData = response['data']['user'];
        _user = User.fromJson(userData);
        _isLoggedIn = true;
        
        // Actualizar datos guardados
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, jsonEncode(userData));
        
        print('✅ Usuario actual obtenido: ${_user!.name}');
        notifyListeners();
        return true;
      }
      
      print('❌ Error obteniendo usuario: ${response['message']}');
      return false;
    } catch (e) {
      print('🚨 Error getting current user: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
  }) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _setError(null);

    try {
      final updateData = <String, dynamic>{};
      
      if (name != null && name != _user!.name) updateData['name'] = name;
      if (email != null && email != _user!.email) updateData['email'] = email;
      if (phone != null && phone != _user!.phone) updateData['phone'] = phone;
      if (address != null && address != _user!.address) updateData['address'] = address;
      if (birthDate != null && birthDate != _user!.birthDate) updateData['birth_date'] = birthDate;
      if (gender != null && gender != _user!.gender) updateData['gender'] = gender;
      
      if (updateData.isEmpty) return true; // No hay cambios
      
      final response = await _apiService.updateProfile(updateData);
      
      if (response['success'] == true) {
        await getCurrentUser(); // Refrescar datos del usuario
        return true;
      }
      
      _setError(response['message'] ?? 'Error al actualizar perfil');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }

  Future<void> _loadUserProfile() async {
    try {
      print('🔄 Cargando perfil de usuario...');
      final userResponse = await _apiService.getCurrentUser();
      
      if (userResponse['success'] == true) {
        _user = User.fromJson(userResponse['data']['user']);
        
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, jsonEncode(userResponse['data']['user']));
        
        print('✅ Perfil cargado: ${_user!.name}');
      } else {
        print('❌ Error cargando perfil: ${userResponse['message']}');
      }
    } catch (e) {
      print('🚨 Error en _loadUserProfile: $e');
    }
  }

  bool get isClient => _user?.role == 'client';
  bool get isAdmin => _user?.role == 'admin';
  bool get isStaff => _user?.role == 'staff' || _user?.role == 'admin';
}