import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/product/presentation/providers/product_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/cart_provider.dart';
import 'package:fashion_ecommerce/shared/widgets/loading_indicator.dart';
import 'package:fashion_ecommerce/shared/widgets/error_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedSize = 41;
  bool _isDescriptionExpanded = false;

  final List<int> _availableSizes = [40, 41, 42, 43];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProductDetail(widget.productId);
    });
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Memuat detail sepatu...');
          }

          if (provider.error != null) {
            return AppErrorWidget(
              message: provider.error!,
              onRetry: () => provider.fetchProductDetail(widget.productId),
            );
          }

          final product = provider.selectedProduct;
          if (product == null) {
            return const AppErrorWidget(message: 'Sepatu tidak ditemukan');
          }

          return Stack(
            children: [
              // Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top App Bar & Gallery Hero Section
                    _buildGalleryHeader(product),

                    // 2. Product Information Details
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            product.name,
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Premium Price Hierarchy & Discount Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              // Final Price (Main bold promo red)
                              Text(
                                'Rp ${_formatPrice(product.price)}',
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFE53935),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Original Strikethrough Price
                              Text(
                                'Rp ${_formatPrice(product.price * 1.25)}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Discount Badge Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFEF9A9A)),
                                ),
                                child: const Text(
                                  '20% OFF',
                                  style: TextStyle(
                                    color: Color(0xFFC62828),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Savings Note / Voucher Embel-embel
                          Row(
                            children: [
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedTicket01,
                                color: Color(0xFF2E7D32),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Hemat 20% + Potongan Voucher Spesial Toko saat checkout',
                                  style: AppTextStyles.caption.copyWith(
                                    color: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Rating & Sold Row (Stitch UI Badge)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E2E1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '6,378 sold',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedStar,
                                color: const Color(0xFFFFC107),
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '4.9 ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '(6,573 reviews)',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE9ECEF)),
                          const SizedBox(height: 16),

                          // Description Section
                          Text('Description', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDescriptionExpanded = !_isDescriptionExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _isDescriptionExpanded ? 'view less' : 'view more..',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Size & Quantity Selectors Container
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Size Selector
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Size', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _availableSizes.map((size) {
                                        final isSelected = _selectedSize == size;
                                        return GestureDetector(
                                          onTap: () => setState(() => _selectedSize = size),
                                          child: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.primary : Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : const Color(0xFFC4C7C7),
                                                width: 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '$size',
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Quantity Selector
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quantity', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F3F2),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (_quantity > 1) {
                                              setState(() => _quantity--);
                                            }
                                          },
                                          child: const Text(
                                            '-',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          child: Text(
                                            '$_quantity',
                                            style: AppTextStyles.h3.copyWith(fontSize: 15),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() => _quantity++);
                                          },
                                          child: const Text(
                                            '+',
                                            style: TextStyle(
                                              fontSize: 18,
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
                          const SizedBox(height: 24),
                          const Divider(color: Color(0xFFE9ECEF)),
                          const SizedBox(height: 16),

                          // Customer Reviews Section (Stitch UI)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const HugeIcon(
                                    icon: HugeIcons.strokeRoundedStar,
                                    color: Color(0xFFFFC107),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '4.8 (5,775 reviews)',
                                    style: AppTextStyles.h3.copyWith(fontSize: 17),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => context.push('/reviews'),
                                child: Text(
                                  'See All',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildReviewPreviewCard(
                            name: 'Darlene Robertson',
                            avatarUrl:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAvzNAQ2xRzc-iekDdeuq9BV4EnU_5ScdmSci1UOloXZnqkP_p4_PXnQ08Vj5FZDOhIhrYqksph5uUs8c_vUnE_dcK3D8QyMtEYjxz_jSEFBkxmgXCtGgjwJwcRJe5Txd40EK2Aq6GqzWFFRCFwIc940NuCtyIheUttKEQA-uBAkEfWfQw0R59AEGBlyKGRDkv6LpU1e6AfsQzR_iIT46LaAAUiBkpQIE83lXmX9iH8Zy3B9D7tXp3J8w',
                            rating: 5,
                            comment:
                                'The item is very good, my son likes it very much and wearing it every day 💯💯💯',
                            likes: 729,
                            timeAgo: '6 days ago',
                          ),
                          const SizedBox(height: 12),
                          _buildReviewPreviewCard(
                            name: 'Jane Cooper',
                            avatarUrl:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAlliD8qnkuNep47XdGn5jlUnYD5V0zz1g5hIuhhUNfACsVr28NbBXkZ9EyyagUKq7ek7pg5w4qEwAjJi77TON36EZDbqm339-G8ScFfG4lmB28NvVtNRRB6McdVXxk96ZTO-hpxTf6SDswb0UALkxMNknS_Vt1RQlGcVQqyoIN5d1hO6Ieieh_HW4X9KgECKmN_DMaFHhM4IrLDLOGY4eSzLkKSItSJ9vKoyXR4sU45avc1xnwTbXfWA',
                            rating: 4,
                            comment:
                                'The seller is very fast in sending packet, I just bought it and the item arrived in just 1 day! 👍👍',
                            likes: 625,
                            timeAgo: '6 days ago',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Sticky Bottom Checkout Bar (2 Options Buttons: + Add to Cart & Buy Now)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(
                      top: BorderSide(color: Color(0xFFE9ECEF), width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // 1. Add to Cart Button (Large Outlined)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<CartProvider>().addItem(
                                    product,
                                    _quantity,
                                  );
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} (Size $_selectedSize) added to cart!',
                                  ),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              side: const BorderSide(color: AppColors.primary, width: 2.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedShoppingBag01,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            label: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // 2. Buy Now Button (Large Solid Primary)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<CartProvider>().addItem(
                                    product,
                                    _quantity,
                                  );
                              context.push('/order-form');
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
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

  Widget _buildGalleryHeader(dynamic product) {
    return Container(
      width: double.infinity,
      height: 320,
      color: const Color(0xFFF1EDEC),
      child: Stack(
        children: [
          // Shoe Image (Transparent background via BlendMode.multiply)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFFF1EDEC),
                  BlendMode.multiply,
                ),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl ?? '',
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const HugeIcon(
                    icon: HugeIcons.strokeRoundedRunningShoes,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                  errorWidget: (_, __, ___) => const HugeIcon(
                    icon: HugeIcons.strokeRoundedRunningShoes,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
          ),

          // Top Header Buttons (Back on Left, Cart & Favorite on Right)
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                Consumer2<ProductProvider, CartProvider>(
                  builder: (context, productProvider, cartProvider, _) {
                    final isFav = productProvider.isFavorite(product.id as String);
                    return Row(
                      children: [
                        // Cart Button with badge count
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white.withValues(alpha: 0.9),
                              child: IconButton(
                                onPressed: () => context.push('/cart'),
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedShoppingBag01,
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                            if (cartProvider.itemCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cartProvider.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),

                        // Favorite Heart Button
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          child: IconButton(
                            onPressed: () {
                              productProvider.toggleFavorite(product.id as String);
                            },
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? AppColors.accent : AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Gallery Pagination Dots
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                ...List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC4C7C7),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPreviewCard({
    required String name,
    required String avatarUrl,
    required int rating,
    required String comment,
    required int likes,
    required String timeAgo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 10, color: AppColors.primary),
                    const SizedBox(width: 2),
                    Text(
                      '$rating',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('$likes', style: AppTextStyles.caption.copyWith(fontSize: 11)),
              const SizedBox(width: 16),
              Text(timeAgo, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
