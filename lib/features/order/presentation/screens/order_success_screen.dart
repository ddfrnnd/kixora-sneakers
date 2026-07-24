import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/core/utils/receipt_helper.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animated Success Check Icon
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Lottie.asset(
                    'assets/animated/Success Check.json',
                    repeat: false,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                          size: 80,
                          color: AppColors.success,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Pesanan Sepatu Berhasil! 🎉',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  'Terima kasih atas pesanan Anda di SoleStep Footwear.\nPesanan sedang diproses dan siap dikirim ke alamat Anda.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                CustomButton(
                  text: 'Simpan Resi Transaksi (PDF)',
                  icon: HugeIcons.strokeRoundedFile02,
                  onPressed: () async {
                    await ReceiptHelper.saveReceiptToDevice(
                      context: context,
                      orderId: '#SLS-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                      recipientName: 'Pelanggan SoleStep',
                      recipientPhone: '081234567890',
                      address: 'Jl. Pemuda No. 88, Kota Tegal, Jawa Tengah',
                      totalPrice: 2499000,
                      items: [
                        {
                          'name': 'Nike Air Jordan 1 High OG',
                          'quantity': 1,
                          'price': 2499000.0,
                        }
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: 'Kembali ke Beranda',
                  isOutlined: true,
                  icon: HugeIcons.strokeRoundedHome01,
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: 'Lihat Katalog Sepatu',
                  isOutlined: true,
                  icon: HugeIcons.strokeRoundedGrid,
                  onPressed: () => context.go('/products'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
