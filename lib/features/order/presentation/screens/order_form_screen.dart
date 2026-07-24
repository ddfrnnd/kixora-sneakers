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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Default to GPS location at start
      context.read<LocationProvider>().getCurrentLocation();

      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.user != null && _nameController.text.isEmpty) {
        _nameController.text = auth.user!.name;
      }

      // Pre-select default profile address
      _selectedProfileAddress = _savedProfileAddresses.firstWhere((a) => a.isDefault, orElse: () => _savedProfileAddresses.first);
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

  void _selectSavedProfileAddress(SavedProfileAddress addr) {
    setState(() {
      _selectedProfileAddress = addr;
      _addressController.text = addr.fullAddress;
    });

    // Update location provider coordinates
    context.read<LocationProvider>().setManualLocation(addr.latitude, addr.longitude);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alamat dipilih dari profil: ${addr.label}'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
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
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<LocationProvider>().getCurrentLocation();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mengambil lokasi GPS terbaru...'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
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

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;

    final locationState = context.read<LocationProvider>();
    if (locationState.latitude == null || locationState.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tentukan alamat atau lokasi GPS terlebih dahulu'),
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
              // 1. Shipping Address Options Bar (GPS vs Saved Profile Address)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Alamat Pengiriman', style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => _showSavedAddressPickerModal(context),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedHome01, color: AppColors.primary, size: 16),
                    label: const Text('Pilih Alamat Profil ➔', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // GPS Location Card Option
              Consumer<LocationProvider>(
                builder: (context, location, _) {
                  return Column(
                    children: [
                      GpsLocationCard(
                        latitude: location.latitude,
                        longitude: location.longitude,
                        isLoading: location.isLoading,
                        error: location.error,
                        onRefresh: () {
                          setState(() => _selectedProfileAddress = null);
                          location.getCurrentLocation();
                        },
                      ),
                      const SizedBox(height: 10),
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

              // 3. Choose Shipping Type
              Text('Metode Pengiriman', style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
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
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedDeliveryTruck01,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Express Delivery (GPS Live Tracking)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Promo Code
              Text('Kode Voucher Promo', style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
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
                          hintText: 'Masukkan Kode Promo (contoh: SOLESTEP20)',
                          hintStyle: TextStyle(fontSize: 13),
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
                      icon: const HugeIcon(
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
            text: 'Lanjutkan ke Pembayaran',
            icon: HugeIcons.strokeRoundedArrowRight01,
            onPressed: _submitOrder,
          ),
        ),
      ),
    );
  }
}
