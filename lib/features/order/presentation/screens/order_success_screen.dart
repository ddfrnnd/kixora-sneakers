import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/core/utils/receipt_helper.dart';
import 'package:fashion_ecommerce/features/order/domain/entities/order.dart' as entity;
import 'package:fashion_ecommerce/shared/widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final entity.Order? order;

  const OrderSuccessScreen({super.key, this.order});

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final String orderId = order?.id ?? '';
    final String displayId = orderId.length > 8
        ? orderId.substring(0, 8).toUpperCase()
        : (orderId.isNotEmpty ? orderId.toUpperCase() : 'SOLESTEP-88');

    final double totalPay = order?.totalPrice ?? 0.0;
    final String customerName = order?.customerName ?? 'Pelanggan SoleStep';
    final String customerPhone = order?.customerPhone ?? '081234567890';
    final String address = order?.address ?? 'Alamat Pemesanan';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Lottie Animated Success Check Icon
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/animated/Success Check.json',
                    repeat: false,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                          size: 90,
                          color: AppColors.success,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Pesanan Berhasil Dibuat',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Terima kasih telah berbelanja di SoleStep Footwear.\nPesanan Anda telah tersimpan dan siap diproses ke alamat tujuan.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Order Brief Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nomor Transaksi', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        Text('#$displayId', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Metode Pembayaran', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('COD (Bayar di Tempat)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFE9ECEF)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: AppTextStyles.h3.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('Rp ${_formatPrice(totalPay)}', style: AppTextStyles.price.copyWith(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Primary Action: Lacak Pesanan
              CustomButton(
                text: 'Lacak Pengiriman Pesanan',
                icon: HugeIcons.strokeRoundedGps01,
                onPressed: () {
                  if (orderId.isNotEmpty) {
                    context.push('/order-tracking/$orderId');
                  } else {
                    context.push('/order-tracking', extra: order);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Secondary Action: Download / Print PDF Struk
              CustomButton(
                text: 'Cetak Struk Pembayaran',
                isOutlined: true,
                icon: HugeIcons.strokeRoundedFile02,
                onPressed: () async {
                  await ReceiptHelper.saveReceiptToDevice(
                    context: context,
                    orderId: '#SLS-$displayId',
                    recipientName: customerName,
                    recipientPhone: customerPhone,
                    address: address,
                    totalPrice: totalPay,
                    items: order?.items.map((i) => {
                          'name': i.productName ?? 'Sepatu Authentic',
                          'quantity': i.quantity,
                          'price': i.price,
                        }).toList() ??
                        [
                          {
                            'name': 'Nike Air Jordan 1 High OG',
                            'quantity': 1,
                            'price': totalPay,
                          }
                        ],
                  );
                },
              ),
              const SizedBox(height: 12),

              // Tertiary Action: Kembali ke Halaman Utama
              CustomButton(
                text: 'Kembali ke Halaman Utama',
                isOutlined: true,
                icon: HugeIcons.strokeRoundedHome01,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
