import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/features/admin/presentation/providers/admin_provider.dart';
import 'package:fashion_ecommerce/features/admin/presentation/widgets/order_status_badge.dart';
import 'package:fashion_ecommerce/features/admin/presentation/widgets/customer_location_map.dart';
import 'package:fashion_ecommerce/shared/widgets/loading_indicator.dart';
import 'package:fashion_ecommerce/shared/widgets/error_widget.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() =>
      _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchOrderDetail(widget.orderId);
    });
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.isLoading) {
            return const LoadingIndicator(
                message: 'Memuat detail pesanan...');
          }

          if (admin.error != null) {
            return AppErrorWidget(
              message: admin.error!,
              onRetry: () => admin.fetchOrderDetail(widget.orderId),
            );
          }

          final order = admin.selectedOrder;
          if (order == null) {
            return const AppErrorWidget(
                message: 'Pesanan tidak ditemukan');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: AppTextStyles.h4,
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(order.createdAt),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Customer Info
                _buildSection(
                  title: 'Data Pelanggan',
                  icon: HugeIcons.strokeRoundedUser,
                  children: [
                    _buildInfoRow('Nama', order.customerName),
                    _buildInfoRow('No. HP', order.customerPhone),
                    _buildInfoRow('Alamat', order.address),
                  ],
                ),
                const SizedBox(height: 16),

                // Location Map
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: CustomerLocationMap(
                    latitude: order.latitude,
                    longitude: order.longitude,
                    customerName: order.customerName,
                  ),
                ),
                const SizedBox(height: 16),

                // Order Items
                _buildSection(
                  title: 'Pesanan',
                  icon: HugeIcons.strokeRoundedShoppingBag01,
                  children: [
                    ...order.items.map((item) => Padding(
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
                                child: item.imageUrl != null
                                    ? Image.network(
                                        item.imageUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => const HugeIcon(
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: AppTextStyles.labelLarge,
                                    ),
                                    Text(
                                      '${item.quantity}x Rp ${_formatPrice(item.price)}',
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
                          'Rp ${_formatPrice(order.totalPrice)}',
                          style: AppTextStyles.price,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Update Status
                Text('Update Status', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusButton(
                      context,
                      'Baru',
                      order.status == 'Baru',
                      AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    _buildStatusButton(
                      context,
                      'Diproses',
                      order.status == 'Diproses',
                      const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    _buildStatusButton(
                      context,
                      'Dikirim',
                      order.status == 'Dikirim',
                      const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 6),
                    _buildStatusButton(
                      context,
                      'Selesai',
                      order.status == 'Selesai',
                      AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
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

  Widget _buildStatusButton(
    BuildContext context,
    String status,
    bool isActive,
    Color color,
  ) {
    return Expanded(
      child: InkWell(
        onTap: isActive
            ? null
            : () async {
                final admin = context.read<AdminProvider>();
                final success = await admin.updateOrderStatus(
                  widget.orderId,
                  status,
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status diubah ke $status'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
