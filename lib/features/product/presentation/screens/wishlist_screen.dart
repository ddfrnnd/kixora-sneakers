import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/product/presentation/providers/product_provider.dart';
import 'package:fashion_ecommerce/shared/widgets/product_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _selectedBrandFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final allFavorites = productProvider.favoriteProducts;

    // Filter by Brand category chip
    final filteredFavorites = allFavorites.where((p) {
      if (_selectedBrandFilter == 'All') return true;
      return p.category.toLowerCase().contains(_selectedBrandFilter.toLowerCase()) ||
             p.name.toLowerCase().contains(_selectedBrandFilter.toLowerCase());
    }).toList();

    final brands = ['All', 'Nike', 'Adidas', 'Jordan', 'Puma', 'Converse', 'New Balance'];

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
          'My Wishlist',
          style: AppTextStyles.h2.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/products'),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal Category Chips (Stitch Design)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final isSelected = _selectedBrandFilter == brand;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      brand,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedBrandFilter = brand;
                        });
                      }
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          // 2. Wishlist Grid / Empty State
          Expanded(
            child: allFavorites.isEmpty
                ? _buildEmptyState()
                : filteredFavorites.isEmpty
                    ? _buildFilteredEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.64,
                        ),
                        itemCount: filteredFavorites.length,
                        itemBuilder: (context, index) {
                          final product = filteredFavorites[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              context.push('/products/${product.id}');
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedFavourite,
                size: 56,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Wishlist Anda Kosong',
              style: AppTextStyles.h2.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Jelajahi katalog kami dan ketuk ikon hati pada sepatu favorit Anda untuk menyimpannya di sini.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/products'),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedRunningShoes,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Mulai Belanja',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedInbox,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Sepatu Favorit',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Anda belum memfavoritkan produk sepatu dari brand $_selectedBrandFilter.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
