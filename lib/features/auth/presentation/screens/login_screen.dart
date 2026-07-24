import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/core/utils/validator.dart';
import 'package:fashion_ecommerce/features/auth/presentation/providers/auth_provider.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_button.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_text_field.dart';
import 'package:hugeicons/hugeicons.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedSettings01,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Login Admin', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk mengelola pesanan',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  CustomTextField(
                    label: 'Email',
                    hint: 'admin@solestep.com',
                    controller: _emailController,
                    validator: Validator.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedMail01),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),

                  // Password
                  CustomTextField(
                    label: 'Password',
                    hint: 'Masukkan password',
                    controller: _passwordController,
                    validator: Validator.validatePassword,
                    obscureText: _obscurePassword,
                    prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedLock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: HugeIcon(
                        icon: _obscurePassword
                            ? HugeIcons.strokeRoundedViewOff
                            : HugeIcons.strokeRoundedEye,
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.error != null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const HugeIcon(icon: HugeIcons.strokeRoundedAlertCircle, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.error!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Login button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return CustomButton(
                        text: 'Masuk',
                        icon: HugeIcons.strokeRoundedLogin01,
                        isLoading: auth.isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await auth.login(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                            if (success && context.mounted) {
                              if (auth.isAdmin) {
                                context.go('/admin');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Selamat datang, ${auth.user?.name ?? 'Pelanggan'}!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                context.go('/home');
                              }
                            }
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? '),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: const Text(
                          'Daftar di sini',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Back to home
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
