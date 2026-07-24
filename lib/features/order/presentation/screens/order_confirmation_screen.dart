import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/order/domain/entities/order.dart' as entity;
import 'package:fashion_ecommerce/features/order/presentation/providers/cart_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/order_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/location_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/widgets/map_preview_widget.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_button.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final cartProvider = context.watch<CartProvider>();
    final locationProvider = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info
            _buildSectionCard(
              title: 'Data Pelanggan',
              icon: HugeIcons.strokeRoundedUser,
              children: [
                _buildInfoRow('Nama', orderProvider.customerName),
                _buildInfoRow('No. HP', orderProvider.customerPhone),
                _buildInfoRow('Alamat', orderProvider.address),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            _buildSectionCard(
              title: 'Lokasi Pengiriman',
              icon: HugeIcons.strokeRoundedLocation01,
              children: [
                if (locationProvider.hasLocation) ...[
                  _buildInfoRow(
                    'Koordinat',
                    '${locationProvider.latitude!.toStringAsFixed(6)}, ${locationProvider.longitude!.toStringAsFixed(6)}',
                  ),
                  const SizedBox(height: 12),
                  MapPreviewWidget(
                    latitude: locationProvider.latitude!,
                    longitude: locationProvider.longitude!,
                    height: 150,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Order Items
            _buildSectionCard(
              title: 'Pesanan (${cartProvider.totalQuantity} item)',
              icon: HugeIcons.strokeRoundedShoppingBag01,
              children: [
                ...cartProvider.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F3F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: item.product.imageUrl != null
                                ? Image.network(
                                    item.product.imageUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const HugeIcon(
                                      icon: HugeIcons.strokeRoundedRunningShoes,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const HugeIcon(
                                    icon: HugeIcons.strokeRoundedRunningShoes,
                                    color: AppColors.primary,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: AppTextStyles.labelLarge,
                                ),
                                Text(
                                  '${item.quantity}x Rp ${_formatPrice(item.product.price)}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(item.subtotal)}',
                            style: AppTextStyles.priceSmall,
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.h4),
                    Text(
                      'Rp ${_formatPrice(cartProvider.totalPrice)}',
                      style: AppTextStyles.price,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Order
            Consumer<OrderProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: [
                    if (provider.error != null) ...[
                      Container(
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
                                provider.error!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    CustomButton(
                      text: 'Kirim Pesanan',
                      icon: HugeIcons.strokeRoundedSendToMobile,
                      isLoading: provider.isLoading,
                      onPressed: () async {
                        final order = entity.Order(
                          customerName: orderProvider.customerName,
                          customerPhone: orderProvider.customerPhone,
                          address: orderProvider.address,
                          latitude: locationProvider.latitude!,
                          longitude: locationProvider.longitude!,
                          items: cartProvider.toOrderItems(),
                          totalPrice: cartProvider.totalPrice,
                        );

                        final success = await provider.createOrder(order);
                        if (success && context.mounted) {
                          cartProvider.clearCart();
                          context.go('/order-success');
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<List<dynamic>> icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(icon: icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          const Text(': '),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
