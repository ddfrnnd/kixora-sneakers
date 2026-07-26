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

class SavedProfileAddress {
  final String id;
  final String label;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final bool isDefault;

  SavedProfileAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });
}

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

  SavedProfileAddress? _selectedProfileAddress;
  String _selectedPaymentMethod = 'COD';
  bool _isSubmitting = false;

  final List<SavedProfileAddress> _savedProfileAddresses = [
    SavedProfileAddress(
      id: '1',
      label: 'Home (Utama)',
      fullAddress: 'Jl. Sudirman No. 45, Jakarta Selatan, 12190',
      latitude: -6.2088,
      longitude: 106.8456,
      isDefault: true,
    ),
    SavedProfileAddress(
      id: '2',
      label: 'Office / Kantor',
      fullAddress: 'Gedung Menara Mandiri Lt. 12, Jl. Jend. Gatot Subroto, Jakarta Pusat',
      latitude: -6.1754,
      longitude: 106.8272,
    ),
    SavedProfileAddress(
      id: '3',
      label: 'Apartment',
      fullAddress: 'Tower B Lt. 18 Unit 05, Apt. Sudirman Hill, Jakarta',
      latitude: -6.2297,
      longitude: 106.8091,
    ),
    SavedProfileAddress(
      id: '4',
      label: "Rumah Orang Tua",
      fullAddress: 'Jl. Melati Indah No. 12, Kebayoran Baru, Jakarta Selatan',
      latitude: -6.1912,
      longitude: 106.8234,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.user != null && _nameController.text.isEmpty) {
        _nameController.text = auth.user!.name;
      }

      // Pre-select default profile address & set map coordinates to saved profile address
      final defaultAddr = _savedProfileAddresses.firstWhere((a) => a.isDefault, orElse: () => _savedProfileAddresses.first);
      _selectSavedProfileAddress(defaultAddr, showToast: false);
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

  void _selectSavedProfileAddress(SavedProfileAddress addr, {bool showToast = true}) {
    setState(() {
      _selectedProfileAddress = addr;
      _addressController.text = addr.fullAddress;
    });

    // Update location provider address & geocode coordinates to update map preview
    context.read<LocationProvider>().setAddressAndGeocode(
          addr.fullAddress,
          fallbackLat: addr.latitude,
          fallbackLng: addr.longitude,
        );

    if (showToast) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alamat dipilih: ${addr.label}'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSavedAddressPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Alamat dari Profil Anda',
                style: AppTextStyles.h3.copyWith(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih alamat tersimpan atau gunakan GPS lokasi saat ini',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Saved Addresses List
              ..._savedProfileAddresses.map((addr) {
                final isSelected = _selectedProfileAddress?.id == addr.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _selectSavedProfileAddress(addr);
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedHome01,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          addr.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        if (addr.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Utama', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        addr.fullAddress,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: isSelected
                        ? const HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: AppColors.primary,
                            size: 22,
                          )
                        : null,
                  ),
                );
              }),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _selectedProfileAddress = null);
                    final loc = context.read<LocationProvider>();
                    await loc.getCurrentLocation();
                    if (loc.addressText != null && loc.addressText!.isNotEmpty) {
                      _addressController.text = loc.addressText!;
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lokasi GPS berhasil diperbarui ke posisi Anda saat ini.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedGps01, color: AppColors.primary, size: 18),
                  label: const Text('Gunakan Lokasi GPS Saat Ini', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final locationState = context.read<LocationProvider>();
      final double finalLat = locationState.latitude ?? -6.2088;
      final double finalLng = locationState.longitude ?? 106.8456;

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

      final newOrder = entity.Order(
        id: '',
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        latitude: finalLat,
        longitude: finalLng,
        items: orderItems,
        totalPrice: cart.totalPrice,
        status: 'Baru',
        createdAt: DateTime.now(),
      );

      // Save Order directly to Cloud Firestore Database
      final success = await context.read<OrderProvider>().createOrder(newOrder);
      final createdOrder = context.read<OrderProvider>().lastOrder;

      // Clear cart items
      cart.clearCart();

      if (mounted) {
        final String orderId = createdOrder?.id ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan Anda berhasil dibuat dan sedang diproses.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
        context.go('/order-success', extra: createdOrder);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan. Silakan coba kembali.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout Pemesanan', style: AppTextStyles.h2.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HugeIcon(
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
              // 1. Shipping Address Section Header with Ganti Alamat Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Alamat Pengiriman', style: AppTextStyles.h3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => _showSavedAddressPickerModal(context),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedHome01, color: AppColors.primary, size: 16),
                    label: const Text('Ganti Alamat', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // GPS / Selected Address Card Display
              Consumer<LocationProvider>(
                builder: (context, location, _) {
                  final String title = _selectedProfileAddress?.label ?? 'Lokasi GPS Saat Ini';
                  final String currentDisplayAddress = _addressController.text.isNotEmpty
                      ? _addressController.text
                      : (location.addressText != null && location.addressText!.isNotEmpty
                          ? location.addressText!
                          : 'Jl. Sudirman No. 45, Jakarta Selatan, 12190');

                  return Column(
                    children: [
                      GpsLocationCard(
                        addressTitle: title,
                        addressText: currentDisplayAddress,
                        latitude: location.latitude,
                        longitude: location.longitude,
                        isLoading: location.isLoading,
                        error: location.error,
                      ),
                      const SizedBox(height: 10),

                      // Interactive Map Preview
                      if (location.latitude != null && location.longitude != null)
                        MapPreviewWidget(
                          latitude: location.latitude!,
                          longitude: location.longitude!,
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Customer Inputs
              CustomTextField(
                label: 'Nama Penerima',
                hint: 'Masukkan nama Anda',
                controller: _nameController,
                validator: Validator.validateName,
                prefixIcon: const HugeIcon(
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
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCall,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Alamat Detail Pengiriman',
                hint: 'Jalan, Nomor Rumah, RT/RW, Kecamatan...',
                controller: _addressController,
                validator: Validator.validateAddress,
                maxLines: 2,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // 2. Order List Summary Section
              Text('Daftar Produk Sepatu', style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
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
                              ? ColorFiltered(
                                  colorFilter: const ColorFilter.mode(Color(0xFFF7F3F2), BlendMode.multiply),
                                  child: Image.network(
                                    item.product.imageUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => const HugeIcon(
                                      icon: HugeIcons.strokeRoundedRunningShoes,
                                      color: AppColors.primary,
                                    ),
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
                                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
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

              // 3. Choose Payment Method (Metode Pembayaran COD / Transfer / E-Wallet)
              Text('Metode Pembayaran', style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildPaymentOptionCard(
                value: 'COD',
                title: 'COD (Bayar di Tempat)',
                subtitle: 'Bayar tunai kepada kurir saat sepatu sampai di rumah Anda',
                icon: HugeIcons.strokeRoundedMoney01,
                badge: 'Populer & Praktis',
              ),
              const SizedBox(height: 10),

              _buildPaymentOptionCard(
                value: 'Transfer Bank (Virtual Account)',
                title: 'Transfer Bank / Virtual Account',
                subtitle: 'BCA, Bank Mandiri, BNI, BRI (Otomatis terverifikasi)',
                icon: HugeIcons.strokeRoundedCreditCard,
              ),
              const SizedBox(height: 10),

              _buildPaymentOptionCard(
                value: 'E-Wallet & QRIS',
                title: 'E-Wallet & QRIS',
                subtitle: 'GoPay, OVO, ShopeePay, DANA & QRIS All Bank',
                icon: HugeIcons.strokeRoundedQrCode,
              ),
              const SizedBox(height: 24),

              // 4. Cost Summary Section
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
                        Text('Subtotal Produk', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        Text('Rp ${_formatPrice(cart.totalPrice)}', style: AppTextStyles.labelLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ongkos Kirim', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        Text('GRATIS ONGKIR', style: AppTextStyles.labelLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFE9ECEF)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
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

      // Bottom Sticky Button
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
            text: _isSubmitting ? 'Memproses Pesanan...' : 'Buat Pesanan Sekarang (${_selectedPaymentMethod == 'COD' ? 'COD' : 'Bayar'})',
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            isLoading: _isSubmitting,
            onPressed: _submitOrder,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptionCard({
    required String value,
    required String title,
    required String subtitle,
    required List<List<dynamic>>? icon,
    String? badge,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: icon!,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) setState(() => _selectedPaymentMethod = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
