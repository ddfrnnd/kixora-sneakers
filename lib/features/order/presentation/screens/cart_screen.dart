import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/cart_provider.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_button.dart';
import 'package:fashion_ecommerce/shared/widgets/empty_state_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showRemoveConfirmation(BuildContext context, String productId, String productName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E2E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Remove From Cart?',
                style: AppTextStyles.h2.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to remove "$productName" from your cart?',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CartProvider>().removeItem(productId);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'Yes, Remove',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Cart', style: AppTextStyles.h2.copyWith(fontSize: 22)),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/products'),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return EmptyStateWidget(
              title: 'Keranjang Kosong',
              subtitle: 'Tambahkan sepatu favoritmu dari katalog',
              icon: HugeIcons.strokeRoundedShoppingBag01,
              action: CustomButton(
                text: 'Lihat Katalog Sepatu',
                width: 220,
                onPressed: () => context.go('/home'),
              ),
            );
          }

          return Stack(
            children: [
              // Cart items list
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container (Stitch UI: w-24 h-24 bg-surface-container-low rounded-2xl)
                        Container(
                          width: 90,
                          height: 90,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F3F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: item.product.imageUrl != null
                              ? ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFF7F3F2),
                                    BlendMode.multiply,
                                  ),
                                  child: Image.network(
                                    item.product.imageUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const HugeIcon(
                                      icon: HugeIcons.strokeRoundedRunningShoes,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                )
                              : const HugeIcon(
                                  icon: HugeIcons.strokeRoundedRunningShoes,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                        ),
                        const SizedBox(width: 16),

                        // Info & Controls
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: AppTextStyles.labelLarge.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showRemoveConfirmation(
                                      context,
                                      item.product.id,
                                      item.product.name,
                                    ),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedDelete02,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Color & Size Subtitle Row (Stitch UI: Black | Size 42)
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Black | Size 41',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Price & Quantity Control
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${_formatPrice(item.product.price)}',
                                    style: AppTextStyles.price.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // Qty Pill (- 1 +)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F3F2),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (item.quantity > 1) {
                                              cart.updateQuantity(
                                                item.product.id,
                                                item.quantity - 1,
                                              );
                                            } else {
                                              _showRemoveConfirmation(
                                                context,
                                                item.product.id,
                                                item.product.name,
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '-',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          child: Text(
                                            '${item.quantity}',
                                            style: AppTextStyles.labelLarge
                                                .copyWith(fontSize: 14),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            cart.updateQuantity(
                                              item.product.id,
                                              item.quantity + 1,
                                            );
                                          },
                                          child: const Text(
                                            '+',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Bottom Bar: Total Price + Checkout Button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(
                      top: BorderSide(color: Color(0xFFE9ECEF), width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Price',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice(cart.totalPrice)}',
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/order-form'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(170, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 4,
                          ),
                          label: const Text(
                            'Checkout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
