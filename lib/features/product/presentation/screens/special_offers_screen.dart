import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';

class SpecialOffersScreen extends StatelessWidget {
  const SpecialOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      _OfferData(
        discount: '25%',
        title: "Today's Special!",
        subtitle: 'Get discount for every order, only valid for today',
        voucherCode: 'SPECIAL25',
        gradientColors: [const Color(0xFFE53935), const Color(0xFFB71C1C)],
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80',
        shoeName: 'Nike Air Max Red Edition',
      ),
      _OfferData(
        discount: '20%',
        title: 'Weekends Deals',
        subtitle: 'Special weekend discounts for all premium sneakers',
        voucherCode: 'WEEKEND20',
        gradientColors: [const Color(0xFF8D6E63), const Color(0xFF4E342E)],
        imageUrl: 'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=600&q=80',
        shoeName: 'Adidas Suede Earth Edition',
      ),
      _OfferData(
        discount: '15%',
        title: 'New Arrivals',
        subtitle: 'Explore latest releases & exclusive streetwear models',
        voucherCode: 'NEW15',
        gradientColors: [const Color(0xFF4A6572), const Color(0xFF232F34)],
        imageUrl: 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=600&q=80',
        shoeName: 'Air Force Teal Runner',
      ),
      _OfferData(
        discount: '30%',
        title: 'Black Friday Sale',
        subtitle: 'Mega discounts on all top tier brands & limited editions',
        voucherCode: 'BLACK30',
        gradientColors: [const Color(0xFF3F51B5), const Color(0xFF1A237E)],
        imageUrl: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?auto=format&fit=crop&w=600&q=80',
        shoeName: 'Puma Sapphire Speed',
      ),
      _OfferData(
        discount: '50%',
        title: 'Flash Sale Exclusive',
        subtitle: 'Limited time half-price deal on selected catalog',
        voucherCode: 'FLASH50',
        gradientColors: [const Color(0xFF8E24AA), const Color(0xFF4A148C)],
        imageUrl: 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&w=600&q=80',
        shoeName: 'Jordan Violet Retro',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Special Offers',
          style: AppTextStyles.h2.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voucher promo diperbarui otomatis hari ini 🎉'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedTicket01,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        itemCount: offers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final offer = offers[index];
          return _buildBannerCard(context, offer);
        },
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, _OfferData offer) {
    return GestureDetector(
      onTap: () => _showPromoDetailSheet(context, offer),
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: offer.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: offer.gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Decorative Circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Left Content Details
            Positioned.fill(
              right: 140,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      offer.discount,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedTicket01,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            offer.voucherCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Shoe Image (Floating Rotated Card Style)
            Positioned(
              right: 12,
              top: 16,
              bottom: 16,
              width: 140,
              child: Transform.rotate(
                angle: -0.18,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      offer.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white24,
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedRunningShoes,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromoDetailSheet(BuildContext context, _OfferData offer) {
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
              const SizedBox(height: 20),

              // Banner Preview Card
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: offer.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: offer.gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      right: 130,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              offer.discount,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.subtitle,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 12,
                      bottom: 12,
                      width: 110,
                      child: Transform.rotate(
                        angle: -0.18,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              offer.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('Detail Promo & Syarat Ketentuan', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                'Dapatkan potongan harga sebesar ${offer.discount} untuk setiap pemesanan sepatu pilihan Anda di aplikasi Kixora Sneakers.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildTnCItem('Potongan diskon ${offer.discount} otomatis dihitung saat checkout.'),
              _buildTnCItem('Gunakan kode voucher "${offer.voucherCode}" pada kolom voucher pesanan.'),
              _buildTnCItem('Promo berlaku untuk semua kategori brand sepatu authentic.'),
              const SizedBox(height: 20),

              // Voucher Code Box with Copy Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedTicket01,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KODE VOUCHER',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          offer.voucherCode,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 18,
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: offer.voucherCode));
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎟️ Kode Voucher "${offer.voucherCode}" berhasil disalin!'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCopy01,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        'Salin Kode',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/products');
                  },
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedRunningShoes,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  label: const Text(
                    'Gunakan Promo & Belanja Sekarang',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTnCItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferData {
  final String discount;
  final String title;
  final String subtitle;
  final String voucherCode;
  final List<Color> gradientColors;
  final String imageUrl;
  final String shoeName;

  _OfferData({
    required this.discount,
    required this.title,
    required this.subtitle,
    required this.voucherCode,
    required this.gradientColors,
    required this.imageUrl,
    required this.shoeName,
  });
}
