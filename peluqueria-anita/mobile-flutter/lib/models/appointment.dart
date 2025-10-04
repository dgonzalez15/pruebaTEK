import 'user.dart';
import 'service.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  final int id;
  final int clientId;
  final int? userId; // Estilista asignado
  final DateTime appointmentDate;
  final String startTime;
  final String? endTime;
  final AppointmentStatus status;
  final String? notes;
  final double? totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones
  final User? client;
  final User? user; // Estilista
  final List<AppointmentDetail>? details;

  Appointment({
    required this.id,
    required this.clientId,
    this.userId,
    required this.appointmentDate,
    required this.startTime,
    this.endTime,
    required this.status,
    this.notes,
    this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.client,
    this.user,
    this.details,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      clientId: json['client_id'] as int,
      userId: json['user_id'] as int?,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String?,
      status: _parseStatus(json['status'] as String),
      notes: json['notes'] as String?,
      totalAmount: json['total_amount'] != null 
          ? double.parse(json['total_amount'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      client: json['client'] != null ? User.fromJson(json['client']) : null,
      user: json['stylist'] != null 
          ? User.fromJson(json['stylist']) 
          : (json['user'] != null ? User.fromJson(json['user']) : null),
      details: json['appointment_details'] != null 
          ? (json['appointment_details'] as List)
              .map((detail) => AppointmentDetail.fromJson(detail))
              .toList()
          : (json['details'] != null 
              ? (json['details'] as List)
                  .map((detail) => AppointmentDetail.fromJson(detail))
                  .toList()
              : null),
    );
  }

  static AppointmentStatus _parseStatus(String status) {
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

  String get statusString {
    switch (status) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
    }
  }

  String get statusDisplayName {
    switch (status) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'user_id': userId,
      'appointment_date': appointmentDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'status': statusString,
      'notes': notes,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    int? id,
    int? clientId,
    int? userId,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    AppointmentStatus? status,
    String? notes,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? client,
    User? user,
    List<AppointmentDetail>? details,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      client: client ?? this.client,
      user: user ?? this.user,
      details: details ?? this.details,
    );
  }

  @override
  String toString() {
    return 'Appointment(id: $id, date: $appointmentDate, status: $statusDisplayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class AppointmentDetail {
  final int id;
  final int appointmentId;
  final int serviceId;
  final double servicePrice;
  final int quantity;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones
  final Service? service;

  AppointmentDetail({
    required this.id,
    required this.appointmentId,
    required this.serviceId,
    required this.servicePrice,
    required this.quantity,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
    this.service,
  });

  factory AppointmentDetail.fromJson(Map<String, dynamic> json) {
    return AppointmentDetail(
      id: json['id'] as int,
      appointmentId: json['appointment_id'] as int,
      serviceId: json['service_id'] as int,
      servicePrice: double.parse((json['unit_price'] ?? json['service_price']).toString()),
      quantity: json['quantity'] as int? ?? 1,
      subtotal: double.parse(json['subtotal'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      service: json['service'] != null ? Service.fromJson(json['service']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'service_id': serviceId,
      'service_price': servicePrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AppointmentDetail(id: $id, serviceId: $serviceId, subtotal: \$${subtotal.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}