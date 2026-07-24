import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';
import 'package:fashion_ecommerce/features/product/presentation/providers/product_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final isFavorite = productProvider.isFavorite(widget.product.id);

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Container (Stitch UI: Aspect ratio square, #F8F9FA background, Rounded 24px)
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Product Image (Full fit contain with transparent background multiply)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFF8F9FA),
                          BlendMode.multiply,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrl ?? '',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          placeholder: (context, url) => const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedRunningShoes,
                              size: 44,
                              color: AppColors.textHint,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedRunningShoes,
                              size: 44,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Favorite Heart Button (Top Right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        productProvider.toggleFavorite(widget.product.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.accent : AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Product Name
          Text(
            widget.product.name,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // 3. Rating & Sold Badge (Stitch UI: Star 4.8 | 7,483 sold)
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedStar,
                color: const Color(0xFFFFC107),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '4.8 | ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDEC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '7,483 sold',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 4. Price
          Text(
            'Rp ${_formatPrice(widget.product.price)}',
            style: AppTextStyles.price.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
