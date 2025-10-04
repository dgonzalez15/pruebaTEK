import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/watermark.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      NotificationService.showWarning(
        context,
        'Debes aceptar los términos y condiciones',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      phone: _phoneController.text.trim(),
    );

    if (success) {
      if (mounted) {
        NotificationService.showSuccess(
          context,
          '¡Registro exitoso! Bienvenido(a)',
        );
        context.go('/home');
      }
    } else {
      if (mounted) {
        NotificationService.showError(
          context,
          authProvider.errorMessage ?? 'Error al registrarse',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Título
                  const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Únete a nuestra comunidad',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Formulario
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            label: 'Nombre completo',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.fieldRequired;
                              }
                              if (value.length < 2) {
                                return 'El nombre debe tener al menos 2 caracteres';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSizes.paddingM),
                          
                          CustomTextField(
                            controller: _emailController,
                            label: AppStrings.email,
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.fieldRequired;
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return AppStrings.invalidEmail;
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSizes.paddingM),
                          
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Teléfono',
                            keyboardType: TextInputType.phone,
                            icon: Icons.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length < 8) {
                                  return 'El teléfono debe tener al menos 8 dígitos';
                                }
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSizes.paddingM),
                          
                          CustomTextField(
                            controller: _passwordController,
                            label: AppStrings.password,
                            obscureText: _obscurePassword,
                            icon: Icons.lock_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.fieldRequired;
                              }
                              if (value.length < 6) {
                                return AppStrings.passwordTooShort;
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSizes.paddingM),
                          
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: AppStrings.confirmPassword,
                            obscureText: _obscureConfirmPassword,
                            icon: Icons.lock_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.fieldRequired;
                              }
                              if (value != _passwordController.text) {
                                return AppStrings.passwordsDontMatch;
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSizes.paddingM),
                          
                          // Términos y condiciones
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Acepto los ',
                                    children: [
                                      TextSpan(
                                        text: 'términos y condiciones',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.paddingL),
                          
                          // Botón de registro
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return CustomButton(
                                text: AppStrings.register,
                                onPressed: authProvider.isLoading ? null : _register,
                                isLoading: authProvider.isLoading,
                                width: double.infinity,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Ya tienes cuenta? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Inicia sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.paddingXL),
                  
                  // Marca de agua
                  const Watermark(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}