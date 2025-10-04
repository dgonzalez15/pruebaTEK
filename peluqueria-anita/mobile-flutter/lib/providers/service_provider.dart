import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class ServiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Service> _services = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> loadServices() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getServices();

      if (response['success'] == true) {
        final List<dynamic> servicesData;
        
        // Manejar diferentes formatos de respuesta
        if (response['data'] is List) {
          servicesData = response['data'];
        } else if (response['data']['data'] is List) {
          servicesData = response['data']['data'];
        } else {
          servicesData = [];
        }

        _services = servicesData
            .map((json) => Service.fromJson(json))
            .where((service) => service.isActive) // Solo servicios activos
            .toList();
        
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Error al cargar servicios');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Service? getServiceById(int id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Service> getServicesByIds(List<int> ids) {
    return _services.where((service) => ids.contains(service.id)).toList();
  }

  double calculateTotalPrice(List<int> serviceIds) {
    double total = 0.0;
    for (final id in serviceIds) {
      final service = getServiceById(id);
      if (service != null) {
        total += service.price;
      }
    }
    return total;
  }

  int calculateTotalDuration(List<int> serviceIds) {
    int totalMinutes = 0;
    for (final id in serviceIds) {
      final service = getServiceById(id);
      if (service != null) {
        totalMinutes += service.durationMinutes;
      }
    }
    return totalMinutes;
  }

  String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  void clearError() {
    _setError(null);
  }

  // Obtener servicios por categoría (si se implementa en el futuro)
  List<Service> getServicesByCategory(String category) {
    // Por ahora retornamos todos, pero se puede implementar filtrado por categoría
    return _services;
  }

  // Buscar servicios por nombre
  List<Service> searchServices(String query) {
    if (query.isEmpty) return _services;
    
    final lowerQuery = query.toLowerCase();
    return _services.where((service) => 
      service.name.toLowerCase().contains(lowerQuery) ||
      (service.description?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  // Obtener servicios ordenados por precio
  List<Service> getServicesSortedByPrice({bool ascending = true}) {
    final sortedServices = List<Service>.from(_services);
    sortedServices.sort((a, b) => 
      ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price)
    );
    return sortedServices;
  }

  // Obtener servicios ordenados por duración
  List<Service> getServicesSortedByDuration({bool ascending = true}) {
    final sortedServices = List<Service>.from(_services);
    sortedServices.sort((a, b) => 
      ascending 
        ? a.durationMinutes.compareTo(b.durationMinutes) 
        : b.durationMinutes.compareTo(a.durationMinutes)
    );
    return sortedServices;
  }
}