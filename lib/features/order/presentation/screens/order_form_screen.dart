import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/core/utils/validator.dart';
import 'package:fashion_ecommerce/features/auth/presentation/providers/auth_provider.dart';
import 'package:fashion_ecommerce/features/order/domain/entities/order.dart' as entity;
import 'package:fashion_ecommerce/features/order/presentation/providers/cart_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/order_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/location_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/widgets/gps_location_card.dart';
import 'package:fashion_ecommerce/features/order/presentation/widgets/map_preview_widget.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_button.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_text_field.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().getCurrentLocation();

      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.user != null && _nameController.text.isEmpty) {
        _nameController.text = auth.user!.name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;

    final locationState = context.read<LocationProvider>();
    if (locationState.latitude == null || locationState.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan ambil lokasi GPS terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();

    final orderItems = cart.items.map((item) {
      return entity.OrderItem(
        productId: item.product.id,
        productName: item.product.name,
        quantity: item.quantity,
        price: item.product.price,
        imageUrl: item.product.imageUrl,
      );
    }).toList();

    final orderDraft = entity.Order(
      id: '',
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      latitude: locationState.latitude!,
      longitude: locationState.longitude!,
      items: orderItems,
      totalPrice: cart.totalPrice,
      status: 'Baru',
      createdAt: DateTime.now(),
    );

    context.read<OrderProvider>().setCustomerName(_nameController.text.trim());
    context.read<OrderProvider>().setCustomerPhone(_phoneController.text.trim());
    context.read<OrderProvider>().setAddress(_addressController.text.trim());

    context.push('/order-confirmation', extra: orderDraft);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.h2.copyWith(fontSize: 22)),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Shipping Address & GPS Location Section (Stitch UI)
              Text('Shipping Address', style: AppTextStyles.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 12),

              // GPS Location Card
              Consumer<LocationProvider>(
                builder: (context, location, _) {
                  return GpsLocationCard(
                    latitude: location.latitude,
                    longitude: location.longitude,
                    isLoading: location.isLoading,
                    error: location.error,
                    onRefresh: () => location.getCurrentLocation(),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Map Preview
              Consumer<LocationProvider>(
                builder: (context, location, _) {
                  if (location.latitude != null && location.longitude != null) {
                    return MapPreviewWidget(
                      latitude: location.latitude!,
                      longitude: location.longitude!,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),

              // Customer Inputs
              CustomTextField(
                label: 'Nama Penerima',
                hint: 'Masukkan nama Anda',
                controller: _nameController,
                validator: Validator.validateName,
                prefixIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Nomor WhatsApp / HP',
                hint: 'Contoh: 081234567890',
                controller: _phoneController,
                validator: Validator.validatePhone,
                keyboardType: TextInputType.phone,
                prefixIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCall,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Alamat Detail',
                hint: 'Jalan, Nomor Rumah, RT/RW, Kecamatan...',
                controller: _addressController,
                validator: Validator.validateAddress,
                maxLines: 2,
                prefixIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // 2. Order List Summary Section
              Text('Order List', style: AppTextStyles.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rp ${_formatPrice(item.product.price)} • Qty: ${item.quantity}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. Choose Shipping Type
              Text('Choose Shipping', style: AppTextStyles.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedDeliveryTruck01,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Express Courier Delivery (GPS Pick)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Promo Code
              Text('Promo Code', style: AppTextStyles.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _promoController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Promo Code',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voucher promo berhasil diterapkan!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedAdd01,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Cost Summary Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        Text('Rp ${_formatPrice(cart.totalPrice)}', style: AppTextStyles.labelLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shipping Fee', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        Text('GRATIS', style: AppTextStyles.labelLarge.copyWith(color: AppColors.success)),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFE9ECEF)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                        Text(
                          'Rp ${_formatPrice(cart.totalPrice)}',
                          style: AppTextStyles.price.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Sticky Button (Stitch UI: Continue to Payment full-width 54px pill button)
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            text: 'Continue to Payment',
            icon: HugeIcons.strokeRoundedArrowRight01,
            onPressed: _submitOrder,
          ),
        ),
      ),
    );
  }
}
