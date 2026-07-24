import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/product/presentation/providers/product_provider.dart';
import 'package:fashion_ecommerce/shared/widgets/product_card.dart';
import 'package:fashion_ecommerce/shared/widgets/loading_indicator.dart';
import 'package:fashion_ecommerce/shared/widgets/error_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class ProductListScreen extends StatefulWidget {
  final String? brand;

  const ProductListScreen({super.key, this.brand});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = ['Nike Air Force', 'Adidas Yeezy', 'Jordan Retro'];

  String _selectedCategoryFilter = 'All';
  String _selectedGenderFilter = 'All';
  String _selectedSortFilter = 'Popular';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (widget.brand != null) {
        provider.setCategory(widget.brand!);
        provider.syncFromKicksDev(query: widget.brand!);
      } else {
        provider.fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E2E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Center(
                      child: Text('Sort & Filter', style: AppTextStyles.h2),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE9ECEF)),
                    const SizedBox(height: 16),

                    // Categories
                    Text('Categories', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Nike', 'Adidas', 'Puma'].map((cat) {
                        final isSelected = _selectedCategoryFilter == cat;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => _selectedCategoryFilter = cat);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: Text(
                              cat,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Gender
                    Text('Gender', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Man', 'Woman', 'Kids'].map((g) {
                        final isSelected = _selectedGenderFilter == g;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => _selectedGenderFilter = g);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: Text(
                              g,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Sort By
                    Text('Sort by', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Popular',
                        'Newest',
                        'Price Low-High',
                      ].map((sort) {
                        final isSelected = _selectedSortFilter == sort;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => _selectedSortFilter = sort);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: Text(
                              sort,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Action Buttons (Reset & Apply)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategoryFilter = 'All';
                                _selectedGenderFilter = 'All';
                                _selectedSortFilter = 'Popular';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: AppColors.primary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: const Text(
                              'Reset',
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
                              final provider = context.read<ProductProvider>();
                              if (_selectedCategoryFilter == 'All') {
                                provider.setCategory('Semua');
                              } else {
                                provider.setSearchQuery(_selectedCategoryFilter);
                              }
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
                              'Apply',
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Back button, Search Input + Clear, Tune Filter Icon)
            _buildSearchHeader(),

            // 2. Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Searches
                    if (_recentSearches.isNotEmpty && _searchController.text.isEmpty)
                      _buildRecentSearches(),

                    // Results Status Header
                    _buildResultsHeader(),

                    // Product Grid or Empty State
                    _buildProductGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 4),
          if (widget.brand != null) ...[
            const Spacer(),
            IconButton(
              onPressed: () => context.push('/products'),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.textPrimary),
              tooltip: 'Search',
            ),
          ] else ...[
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {});
                          context.read<ProductProvider>().setSearchQuery(val);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                          context.read<ProductProvider>().setSearchQuery('');
                        },
                        child: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.textHint, size: 20),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: _showSortFilterBottomSheet,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedFilter, color: AppColors.primary),
            tooltip: 'Filter',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: AppTextStyles.h3.copyWith(fontSize: 18)),
              GestureDetector(
                onTap: () {
                  setState(() => _recentSearches.clear());
                },
                child: Text(
                  'Clear All',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _recentSearches.map((term) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = term;
                  setState(() {});
                  context.read<ProductProvider>().setSearchQuery(term);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0xFFE9ECEF), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        term,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() => _recentSearches.remove(term));
                        },
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final query = _searchController.text.trim();
        final count = provider.products.length;

        String title;
        if (widget.brand != null) {
          title = '${widget.brand!} Shoes';
        } else if (query.isNotEmpty) {
          title = 'Results for "$query"';
        } else {
          title = 'Katalog Sepatu';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
              Text(
                '$count found',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: LoadingIndicator(message: 'Searching sneakers...'),
          );
        }

        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error!,
            onRetry: () => provider.fetchProducts(),
          );
        }

        if (provider.products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedRunningShoes,
                    size: 70,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Not Found', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Sorry, the keyword you entered cannot be found, please check again or search with another keyword.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return ProductCard(
              product: product,
              onTap: () => context.push('/products/${product.id}'),
            );
          },
        );
      },
    );
  }
}
