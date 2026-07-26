import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/auth/presentation/providers/auth_provider.dart';

class AuthHelper {
  AuthHelper._();

  /// Confirms if the user is authenticated.
  /// If logged in, calls [onAuthenticated].
  /// If not logged in, displays a user-friendly dialog prompting to log in.
  static bool checkLoginAndExecute(
    BuildContext context, {
    required VoidCallback onAuthenticated,
    String? message,
  }) {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      onAuthenticated();
      return true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Silakan Login Terlebih Dahulu',
            style: AppTextStyles.h3.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message ?? 'Anda perlu masuk ke akun Anda terlebih dahulu untuk melanjutkannya.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Login Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    return false;
  }
}
