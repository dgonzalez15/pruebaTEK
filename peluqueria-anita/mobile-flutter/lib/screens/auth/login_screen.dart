import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/watermark.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Valores por defecto para testing con usuarios existentes
    _emailController.text = 'anita@peluqueria.com';
    _passwordController.text = 'password123';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('🔘 Botón de login presionado');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Formulario no válido');
      return;
    }

    print('✅ Formulario válido');
    print('📧 Email: ${_emailController.text.trim()}');
    print('🔒 Password: ${_passwordController.text.isNotEmpty ? "***" : "vacío"}');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('🔄 Iniciando proceso de login...');
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    print('📊 Resultado del login: $success');

    if (success) {
      print('✅ Login exitoso, navegando a home');
      if (mounted) {
        context.go('/home');
      }
    } else {
      print('❌ Login fallido: ${authProvider.errorMessage}');
      if (mounted) {
        NotificationService.showError(
          context,
          authProvider.errorMessage ?? 'Error al iniciar sesión',
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
                    width: 100,
                    height: 100,
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
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Título
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
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
                            controller: _passwordController,
                            label: AppStrings.password,
                            obscureText: _obscurePassword,
                            icon: Icons.lock,
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
                          
                          // Recordarme
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              const Text(AppStrings.rememberMe),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  // TODO: Implementar recuperación de contraseña
                                },
                                child: const Text(
                                  AppStrings.forgotPassword,
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.paddingL),
                          
                          // Botón de login
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return CustomButton(
                                text: AppStrings.login,
                                onPressed: authProvider.isLoading ? null : _login,
                                isLoading: authProvider.isLoading,
                                width: double.infinity,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          'Regístrate',
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