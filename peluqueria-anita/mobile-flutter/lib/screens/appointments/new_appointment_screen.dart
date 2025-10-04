import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Datos de la cita
  DateTime? _selectedDate;
  String? _selectedTime;
  List<Service> _selectedServices = [];
  String _notes = '';
  
  // Horarios disponibles (simulados)
  final List<String> _availableTimes = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      serviceProvider.loadServices();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: AppConstants.shortAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: AppConstants.shortAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        return _selectedDate != null;
      case 1:
        return _selectedTime != null;
      case 2:
        return _selectedServices.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTime == null || _selectedServices.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Por favor completa todos los campos requeridos',
        backgroundColor: AppColors.warning,
        textColor: Colors.white,
      );
      return;
    }

    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) {
      Fluttertoast.showToast(
        msg: 'No se pudo obtener el usuario autenticado',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }

    // Formatear servicios con ID y precio
    final services = _selectedServices.map((s) => {
      'service_id': s.id,
      'price': s.price,
    }).toList();

    final success = await appointmentProvider.createAppointment(
      appointmentDate: _selectedDate!,
      startTime: _selectedTime!,
      services: services,
      userId: userId,
      notes: _notes.isNotEmpty ? _notes : null,
    );

    if (success) {
      Fluttertoast.showToast(
        msg: '¡Cita agendada exitosamente!',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
      if (mounted) {
        context.go('/home');
      }
    } else {
      Fluttertoast.showToast(
        msg: appointmentProvider.errorMessage ?? 'Error al agendar cita',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          // Indicador de pasos
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index <= _currentStep;
                
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (index < 3) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),
          
          // Contenido de los pasos
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DateSelectionStep(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                _TimeSelectionStep(
                  selectedTime: _selectedTime,
                  availableTimes: _availableTimes,
                  onTimeSelected: (time) {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                ),
                _ServiceSelectionStep(
                  selectedServices: _selectedServices,
                  onServicesChanged: (services) {
                    setState(() {
                      _selectedServices = services;
                    });
                  },
                ),
                _ConfirmationStep(
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  selectedServices: _selectedServices,
                  notes: _notes,
                  onNotesChanged: (notes) {
                    setState(() {
                      _notes = notes;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Botones de navegación
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: CustomButton(
                      text: 'Anterior',
                      onPressed: _previousStep,
                      isPrimary: false,
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Consumer<AppointmentProvider>(
                    builder: (context, appointmentProvider, child) {
                      if (_currentStep == 3) {
                        return CustomButton(
                          text: 'Confirmar Cita',
                          onPressed: appointmentProvider.isLoading ? null : _bookAppointment,
                          isLoading: appointmentProvider.isLoading,
                        );
                      } else {
                        return CustomButton(
                          text: 'Siguiente',
                          onPressed: _canProceedToNext() ? _nextStep : null,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Resto de las clases helper se mantienen igual...
class _DateSelectionStep extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const _DateSelectionStep({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona la fecha',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            'Elige el día para tu cita',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Expanded(
            child: TableCalendar<DateTime>(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: selectedDate ?? DateTime.now(),
              selectedDayPredicate: (day) {
                return selectedDate != null && isSameDay(selectedDate!, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (selectedDay.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
                  onDateSelected(selectedDay);
                }
              },
              enabledDayPredicate: (day) {
                return day.isAfter(DateTime.now().subtract(const Duration(days: 1)));
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSelectionStep extends StatelessWidget {
  final String? selectedTime;
  final List<String> availableTimes;
  final Function(String) onTimeSelected;

  const _TimeSelectionStep({
    required this.selectedTime,
    required this.availableTimes,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona la hora',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            'Elige la hora que mejor te convenga',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: AppSizes.paddingS,
                mainAxisSpacing: AppSizes.paddingS,
              ),
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                final time = availableTimes[index];
                final isSelected = selectedTime == time;
                
                return InkWell(
                  onTap: () => onTimeSelected(time),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Center(
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceSelectionStep extends StatelessWidget {
  final List<Service> selectedServices;
  final Function(List<Service>) onServicesChanged;

  const _ServiceSelectionStep({
    required this.selectedServices,
    required this.onServicesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona los servicios',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            'Elige uno o más servicios para tu cita',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Expanded(
            child: Consumer<ServiceProvider>(
              builder: (context, serviceProvider, child) {
                if (serviceProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (serviceProvider.services.isEmpty) {
                  return const Center(
                    child: Text('No hay servicios disponibles'),
                  );
                }

                return ListView.builder(
                  itemCount: serviceProvider.services.length,
                  itemBuilder: (context, index) {
                    final service = serviceProvider.services[index];
                    final isSelected = selectedServices.any((s) => s.id == service.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          List<Service> newSelectedServices = List.from(selectedServices);
                          if (value == true) {
                            newSelectedServices.add(service);
                          } else {
                            newSelectedServices.removeWhere((s) => s.id == service.id);
                          }
                          onServicesChanged(newSelectedServices);
                        },
                        title: Text(
                          service.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (service.description != null)
                              Text(service.description!),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '\$${service.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.paddingM),
                                Text(
                                  '${service.durationMinutes} min',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        activeColor: AppColors.primary,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationStep extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final List<Service> selectedServices;
  final String notes;
  final Function(String) onNotesChanged;

  const _ConfirmationStep({
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedServices,
    required this.notes,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = selectedServices.fold<double>(
      0, (sum, service) => sum + service.price,
    );

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirma tu cita',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            'Revisa los detalles antes de confirmar',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          
          // Resumen de la cita
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    icon: Icons.calendar_today,
                    title: 'Fecha',
                    value: selectedDate != null
                        ? DateFormat('EEEE, d MMMM yyyy', 'es').format(selectedDate!)
                        : 'No seleccionada',
                  ),
                  _SummaryRow(
                    icon: Icons.access_time,
                    title: 'Hora',
                    value: selectedTime ?? 'No seleccionada',
                  ),
                  _SummaryRow(
                    icon: Icons.content_cut,
                    title: 'Servicios',
                    value: selectedServices.map((s) => s.name).join(', '),
                  ),
                  _SummaryRow(
                    icon: Icons.attach_money,
                    title: 'Total',
                    value: '\$${totalPrice.toStringAsFixed(2)}',
                    valueColor: AppColors.success,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Notas adicionales
          const Text(
            'Notas adicionales (opcional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe cualquier comentario o solicitud especial...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            onChanged: onNotesChanged,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconS,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}