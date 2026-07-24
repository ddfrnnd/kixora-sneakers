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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedUserAdd01,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Buat Akun Baru', style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  Text(
                    'Daftar untuk mempermudah pemesanan sepatu',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name
                  CustomTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama Anda',
                    controller: _nameController,
                    validator: Validator.validateName,
                    prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedUser),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  CustomTextField(
                    label: 'Email',
                    hint: 'nama@email.com',
                    controller: _emailController,
                    validator: Validator.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedMail01),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                    label: 'Password',
                    hint: 'Minimal 6 karakter',
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
                  const SizedBox(height: 24),

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

                  // Register button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return CustomButton(
                        text: 'Daftar Sekarang',
                        icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                        isLoading: auth.isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await auth.register(
                              _nameController.text.trim(),
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registrasi berhasil! Selamat datang.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              context.go('/home');
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
                      const Text('Sudah punya akun? '),
                      GestureDetector(
                        onTap: () => context.push('/login'),
                        child: const Text(
                          'Masuk di sini',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
