import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;
  String? _statusFilter;
  
  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  String? get statusFilter => _statusFilter;

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setLoadingMore(bool loading) {
    if (_isLoadingMore != loading) {
      _isLoadingMore = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  Future<void> loadAppointments({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _setLoading(true);
    } else if (_isLoading || _isLoadingMore || !_hasMoreData) {
      return;
    } else {
      _setLoadingMore(true);
    }

    _setError(null);

    try {
      final response = await _apiService.getAppointments(
        page: _currentPage,
        perPage: 15,
        status: _statusFilter,
      );

      if (response['success'] == true) {
        final List<dynamic> appointmentsData;
        
        // Manejar diferentes formatos de respuesta
        if (response['data'] is List) {
          appointmentsData = response['data'];
        } else if (response['data']['data'] is List) {
          appointmentsData = response['data']['data'];
        } else {
          appointmentsData = [];
        }

        final newAppointments = appointmentsData
            .map((json) => Appointment.fromJson(json))
            .toList();

        if (refresh || _currentPage == 1) {
          _appointments = newAppointments;
        } else {
          _appointments.addAll(newAppointments);
        }

        // Verificar si hay más datos
        _hasMoreData = newAppointments.length >= 15;
        _currentPage++;
        
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Error al cargar citas');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _setLoadingMore(false);
    }
  }

  Future<bool> createAppointment({
    required DateTime appointmentDate,
    required String startTime,
    required List<Map<String, dynamic>> services,
    required int userId,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.createAppointment({
        'appointment_date': appointmentDate.toIso8601String().split('T')[0],
        'start_time': startTime,
        'services': services,
        'notes': notes,
        'status': 'pending',
        'client_id': userId,
        'user_id': userId,
      });

      if (response['success'] == true) {
        // Refrescar la lista de citas
        await loadAppointments(refresh: true);
        return true;
      } else {
        _setError(response['message'] ?? 'Error al crear cita');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    _setError(null);

    try {
      final response = await _apiService.cancelAppointment(appointmentId);

      if (response['success'] == true) {
        // Actualizar la cita en la lista local
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] = _appointments[index].copyWith(
            status: AppointmentStatus.cancelled,
          );
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['message'] ?? 'Error al cancelar cita');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> rescheduleAppointment({
    required int appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    _setError(null);

    try {
      final response = await _apiService.updateAppointment(appointmentId, {
        'appointment_date': newDate.toIso8601String().split('T')[0],
        'start_time': newTime,
      });

      if (response['success'] == true) {
        // Actualizar la cita en la lista local
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] = _appointments[index].copyWith(
            appointmentDate: newDate,
            startTime: newTime,
          );
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['message'] ?? 'Error al reprogramar cita');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void setStatusFilter(String? status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      loadAppointments(refresh: true);
    }
  }

  void clearFilter() {
    setStatusFilter(null);
  }

  void clearError() {
    _setError(null);
  }

  // Obtener citas por estado
  List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    return _appointments.where((appointment) => appointment.status == status).toList();
  }

  // Obtener próximas citas (confirmadas o pendientes)
  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((appointment) => 
            (appointment.status == AppointmentStatus.confirmed || 
             appointment.status == AppointmentStatus.pending) &&
            appointment.appointmentDate.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  // Obtener historial de citas (completadas o canceladas)
  List<Appointment> getAppointmentHistory() {
    return _appointments
        .where((appointment) => 
            appointment.status == AppointmentStatus.completed ||
            appointment.status == AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }
}