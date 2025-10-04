import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/watermark.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      context.go('/login');
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: Text('No hay datos de usuario disponibles'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar del usuario
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingL),
                  
                  // Información personal
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: AppColors.primary,
                                size: AppSizes.iconM,
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              const Text(
                                'Información Personal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          
                          CustomTextField(
                            controller: _nameController,
                            label: 'Nombre completo',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSizes.paddingM),
                          
                          CustomTextField(
                            controller: _emailController,
                            label: 'Correo electrónico',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El correo es requerido';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSizes.paddingM),
                          
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Teléfono (opcional)',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingL),
                  
                  // Estadísticas del usuario
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: AppColors.primary,
                                size: AppSizes.iconM,
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              const Text(
                                'Estadísticas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.event,
                                  title: 'Citas Totales',
                                  value: '12', // Este valor debería venir del backend
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.check_circle,
                                  title: 'Completadas',
                                  value: '10',
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.paddingS),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.schedule,
                                  title: 'Pendientes',
                                  value: '2',
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.star,
                                  title: 'Puntos',
                                  value: '150',
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingL),
                  
                  // Botones de acción
                  Column(
                    children: [
                      CustomButton(
                        text: 'Guardar Cambios',
                        onPressed: authProvider.isLoading ? null : _saveProfile,
                        isLoading: authProvider.isLoading,
                      ),
                      
                      const SizedBox(height: AppSizes.paddingM),
                      
                      CustomButton(
                        text: 'Cambiar Contraseña',
                        onPressed: () {
                          // TODO: Implementar cambio de contraseña
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Función no implementada aún'),
                            ),
                          );
                        },
                        isPrimary: false,
                      ),
                      
                      const SizedBox(height: AppSizes.paddingM),
                      
                      CustomButton(
                        text: 'Cerrar Sesión',
                        onPressed: _showLogoutConfirmation,
                        isPrimary: false,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.paddingL),
                  
                  // Información de la app
                  Text(
                    'Peluquería Anita v1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppSizes.iconM,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}