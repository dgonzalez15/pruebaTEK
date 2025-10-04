import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/watermark.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      appointmentProvider.loadAppointments(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      appointmentProvider.loadAppointments();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Historial'),
            Tab(text: 'Todas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/new-appointment'),
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentList(
                appointmentProvider.getUpcomingAppointments(),
                appointmentProvider.isLoading && appointmentProvider.appointments.isEmpty,
                'No tienes citas próximas',
                '¡Agenda tu próxima cita con nosotros!',
              ),
              _buildAppointmentList(
                appointmentProvider.getAppointmentHistory(),
                appointmentProvider.isLoading && appointmentProvider.appointments.isEmpty,
                'No hay historial de citas',
                'Tus citas completadas aparecerán aquí',
              ),
              _buildAppointmentList(
                appointmentProvider.appointments,
                appointmentProvider.isLoading && appointmentProvider.appointments.isEmpty,
                'No tienes citas registradas',
                'Comienza agendando tu primera cita',
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/new-appointment'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppointmentList(
    List<Appointment> appointments,
    bool isLoading,
    String emptyTitle,
    String emptySubtitle,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingS),
              Text(
                emptySubtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingL),
              CustomButton(
                text: 'Agendar Cita',
                onPressed: () => context.go('/new-appointment'),
                icon: Icons.add,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
        await appointmentProvider.loadAppointments(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: appointments.length + 1,
        itemBuilder: (context, index) {
          if (index == appointments.length) {
            return Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSizes.paddingM),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXL),
                  child: Watermark(),
                );
              },
            );
          }

          final appointment = appointments[index];
          return AppointmentCard(
            appointment: appointment,
            onTap: () => _showAppointmentDetails(appointment),
          );
        },
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      builder: (context) => AppointmentDetailsSheet(appointment: appointment),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      size: AppSizes.iconS,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM yyyy', 'es').format(appointment.appointmentDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hora: ${appointment.startTime}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      appointment.statusDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingS),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: AppSizes.iconS,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: Text(
                          appointment.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (appointment.totalAmount != null) ...[
                const SizedBox(height: AppSizes.paddingS),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: AppSizes.iconS,
                      color: AppColors.success,
                    ),
                    Text(
                      'Total: \$${appointment.totalAmount!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status) {
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
}

class AppointmentDetailsSheet extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsSheet({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Detalles de la Cita',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingL),
          
          // Fecha y hora
          _DetailRow(
            icon: Icons.calendar_today,
            title: 'Fecha',
            value: DateFormat('EEEE, d MMMM yyyy', 'es').format(appointment.appointmentDate),
          ),
          
          _DetailRow(
            icon: Icons.access_time,
            title: 'Hora',
            value: appointment.startTime,
          ),
          
          // Estado
          _DetailRow(
            icon: Icons.info_outline,
            title: 'Estado',
            value: appointment.statusDisplayName,
          ),
          
          // Notas
          if (appointment.notes != null && appointment.notes!.isNotEmpty)
            _DetailRow(
              icon: Icons.note_outlined,
              title: 'Notas',
              value: appointment.notes!,
            ),
          
          // Total
          if (appointment.totalAmount != null)
            _DetailRow(
              icon: Icons.attach_money,
              title: 'Total',
              value: '\$${appointment.totalAmount!.toStringAsFixed(2)}',
            ),
          
          const SizedBox(height: AppSizes.paddingL),
          
          // Acciones
          if (appointment.status == AppointmentStatus.pending ||
              appointment.status == AppointmentStatus.confirmed) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Reprogramar',
                    onPressed: () {
                      Navigator.of(context).pop();
                      _rescheduleAppointment(context, appointment);
                    },
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    onPressed: () => _cancelAppointment(context),
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _rescheduleAppointment(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime newDate = appointment.appointmentDate;
        String newTime = appointment.startTime;
        
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Reprogramar Cita'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona nueva fecha y hora:'),
                const SizedBox(height: AppSizes.paddingM),
                
                // Selector de fecha
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Fecha'),
                  subtitle: Text(
                    DateFormat('EEEE, d MMMM yyyy', 'es').format(newDate),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: newDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => newDate = date);
                    }
                  },
                ),
                
                // Selector de hora
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Hora'),
                  subtitle: Text(newTime),
                  onTap: () async {
                    final timeParts = newTime.split(':');
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(timeParts[0]),
                        minute: int.parse(timeParts[1]),
                      ),
                    );
                    if (time != null) {
                      setState(() => newTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
                  final success = await appointmentProvider.rescheduleAppointment(
                    appointmentId: appointment.id,
                    newDate: newDate,
                    newTime: newTime,
                  );
                  
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cita reprogramada exitosamente'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appointmentProvider.errorMessage ?? 'Error al reprogramar cita'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _cancelAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: const Text('¿Estás seguro de que deseas cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Cerrar bottom sheet
              
              final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
              await appointmentProvider.cancelAppointment(appointment.id);
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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