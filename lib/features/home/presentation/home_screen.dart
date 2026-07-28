import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/product/presentation/providers/product_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/cart_provider.dart';
import 'package:fashion_ecommerce/features/auth/presentation/providers/auth_provider.dart';
import 'package:fashion_ecommerce/shared/widgets/product_card.dart';
import 'package:fashion_ecommerce/shared/widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedBrandFilter = 'All';
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;

  late final PageController _bannerPageController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  final List<Map<String, dynamic>> _homeBanners = [
    {
      'discount': '25%',
      'title': "Today's Special!",
      'subtitle': 'Get discount for every order, only valid for today',
      'voucherCode': 'SPECIAL25',
      'colors': [const Color(0xFFE53935), const Color(0xFFB71C1C)],
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80',
    },
    {
      'discount': '20%',
      'title': 'Weekends Deals',
      'subtitle': 'Special weekend discounts for all premium sneakers',
      'voucherCode': 'WEEKEND20',
      'colors': [const Color(0xFF8D6E63), const Color(0xFF4E342E)],
      'image': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=600&q=80',
    },
    {
      'discount': '15%',
      'title': 'New Arrivals',
      'subtitle': 'Explore latest releases & exclusive streetwear models',
      'voucherCode': 'NEW15',
      'colors': [const Color(0xFF4A6572), const Color(0xFF232F34)],
      'image': 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=600&q=80',
    },
    {
      'discount': '30%',
      'title': 'Black Friday Sale',
      'subtitle': 'Mega discounts on all top tier brands & limited editions',
      'voucherCode': 'BLACK30',
      'colors': [const Color(0xFF3F51B5), const Color(0xFF1A237E)],
      'image': 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?auto=format&fit=crop&w=600&q=80',
    },
    {
      'discount': '50%',
      'title': 'Flash Sale Exclusive',
      'subtitle': 'Limited time half-price deal on selected catalog',
      'voucherCode': 'FLASH50',
      'colors': [const Color(0xFF8E24AA), const Color(0xFF4A148C)],
      'image': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
    _startBannerAutoSlide();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProductProvider>();
      await provider.fetchProducts();
      await provider.syncFromKicksDev(query: 'nike');
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerPageController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _homeBanners.length;
        _bannerPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _currentNavIndex == 0
            ? _buildHomeContent()
            : _currentNavIndex == 1
            ? _buildCartRedirect()
            : _currentNavIndex == 2
            ? _buildOrdersSection()
            : _buildProfileSection(),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE9ECEF), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, HugeIcons.strokeRoundedHome01, 'Home'),
            _buildNavItem(1, HugeIcons.strokeRoundedShoppingBag01, 'Cart'),
            _buildNavItem(2, HugeIcons.strokeRoundedShoppingCart01, 'Orders'),
            _buildNavItem(3, HugeIcons.strokeRoundedUser, 'Profile'),
          ],
        ),
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => context.push('/cart'),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedShoppingBag01, color: Colors.white),
            label: Text(
              '${cart.totalQuantity} item',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primary,
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, List<List<dynamic>> iconData, String label) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          context.push('/cart');
          return;
        }
        setState(() => _currentNavIndex = index);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: iconData,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top App Bar (Stitch UI Style: User greeting + Avatar + Action icons)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                // User Avatar
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final userName = auth.user?.name ?? 'Dede Fernanda';
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFF1EDEC),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning 👋',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              userName,
                              style: AppTextStyles.h3.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),

                // Action Icons
                IconButton(
                  onPressed: () async {
                    final provider = context.read<ProductProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    await provider.syncFromKicksDev(query: 'jordan');
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          '⚡ Live sepatu dari Kicks.dev API berhasil disinkronkan!',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedRefresh,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  tooltip: 'Sync Live Kicks.dev API',
                ),
                IconButton(
                  onPressed: () => context.push('/wishlist'),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFavourite,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  tooltip: 'Produk Disukai',
                ),
              ],
            ),
          ),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GestureDetector(
              onTap: () => context.push('/products'),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFilter,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 3. Special Offers Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Special Offers', style: AppTextStyles.h3),
                GestureDetector(
                  onTap: () => context.push('/special-offers'),
                  child: Text(
                    'See All',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Hero Auto-Sliding Promo Banner (Identical to Special Offers Screen)
          Column(
            children: [
              SizedBox(
                height: 185,
                child: PageView.builder(
                  controller: _bannerPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  itemCount: _homeBanners.length,
                  itemBuilder: (context, index) {
                    final banner = _homeBanners[index];
                    final colors = banner['colors'] as List<Color>;
                    final voucherCode = banner['voucherCode'] as String;
                    final discount = banner['discount'] as String;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => _showHomePromoDetailSheet(context, banner),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.first.withValues(alpha: 0.35),
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
                                right: 135,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        discount,
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1.0,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        banner['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        banner['subtitle'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.85),
                                          height: 1.25,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                                              voucherCode,
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

                              // Right Floating Rotated Shoe Card
                              Positioned(
                                right: 10,
                                top: 14,
                                bottom: 14,
                                width: 130,
                                child: Transform.rotate(
                                  angle: -0.18,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        banner['image'] as String,
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
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_homeBanners.length, (index) {
                  final isSelected = _currentBannerIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildBrandItem('Nike', svgAsset: 'assets/images/nike.svg'),
                const SizedBox(width: 16),
                _buildBrandItem('Adidas', svgAsset: 'assets/images/adidas.svg'),
                const SizedBox(width: 16),
                _buildBrandItem('Puma', svgAsset: 'assets/images/puma.svg'),
                const SizedBox(width: 16),
                _buildBrandItem(
                  'Converse',
                  svgAsset: 'assets/images/converse.svg',
                ),
                const SizedBox(width: 16),
                _buildBrandItem(
                  'New Balance',
                  svgAsset: 'assets/images/new_balance.svg',
                ),
                const SizedBox(width: 16),
                _buildBrandItem('Reebok', svgAsset: 'assets/images/reebok.svg'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 5. Most Popular Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Most Popular', style: AppTextStyles.h3),
                GestureDetector(
                  onTap: () => context.push('/products'),
                  child: Text(
                    'See All',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pill Filter Tabs (Brand Categories)
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children:
                  [
                    'All',
                    'Nike',
                    'Adidas',
                    'Jordan',
                    'Puma',
                    'Converse',
                    'Vans',
                    'New Balance',
                    'Reebok',
                  ].map((brand) {
                    final isSelected = _selectedBrandFilter == brand;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedBrandFilter = brand);
                          final provider = context.read<ProductProvider>();
                          if (brand == 'All') {
                            provider.resetFilters();
                            provider.fetchProducts();
                          } else {
                            provider.setCategory(brand);
                            provider.syncFromKicksDev(query: brand.toLowerCase());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            brand,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Product Grid
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SizedBox(height: 200, child: LoadingIndicator());
              }

              final products = provider.products;
              if (products.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('Belum ada sepatu untuk kategori ini'),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => context.push('/products/${product.id}'),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBrandItem(String label, {String? svgAsset, List<List<dynamic>>? icon}) {
    return GestureDetector(
      onTap: () async {
        final provider = context.read<ProductProvider>();
        await context.push('/products/brand/${label.toLowerCase()}', extra: label);
        if (mounted) {
          setState(() => _selectedBrandFilter = 'All');
          provider.resetFilters();
        }
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1EDEC),
              shape: BoxShape.circle,
            ),
                    child: svgAsset != null
                ? SvgPicture.asset(
                    svgAsset,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (context) => HugeIcon(
                      icon: icon ?? HugeIcons.strokeRoundedSwatch,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  )
                : HugeIcon(icon: icon ?? HugeIcons.strokeRoundedSwatch, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartRedirect() {
    return const SizedBox.shrink();
  }

  // Orders Tab Screen (Stitch UI Navigation Item 3)
  Widget _buildOrdersSection() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Stitch UI: My Orders)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Orders',
                  style: AppTextStyles.h2.copyWith(fontSize: 22),
                ),
                const Row(
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.textPrimary),
                    SizedBox(width: 16),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedRemoveCircle,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Active vs Completed Tab Bar (Stitch UI)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1.5),
              ),
            ),
            child: const TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textHint,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersListByFilter(isCompletedFilter: false),
                _buildOrdersListByFilter(isCompletedFilter: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersListByFilter({required bool isCompletedFilter}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator(message: 'Memuat pesanan...');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F3F2),
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedShoppingCart01,
                      size: 44,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Belum Ada Pesanan', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    isCompletedFilter
                        ? 'Pesanan yang telah selesai akan tampil di sini'
                        : 'Pesanan aktif sepatu Anda akan muncul di sini',
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

        final allDocs = snapshot.data!.docs;
        final filteredDocs = allDocs.where((doc) {
          final status =
              (doc.data() as Map<String, dynamic>)['status'] ?? 'Baru';
          if (isCompletedFilter) {
            return status == 'Selesai';
          } else {
            return status != 'Selesai';
          }
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              isCompletedFilter
                  ? 'Belum ada pesanan selesai'
                  : 'Tidak ada pesanan aktif',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: filteredDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;
            final docId = filteredDocs[index].id;
            final status = data['status'] ?? 'Baru';
            final totalPrice = (data['total_price'] as num?)?.toDouble() ?? 0;
            final items = (data['items'] as List?) ?? [];
            final firstItemName = items.isNotEmpty
                ? (items.first['product_name'] ?? 'Sepatu')
                : 'Sepatu Authentic';
            final String? firstItemImg = items.isNotEmpty
                ? (items.first['image_url'] ?? items.first['imageUrl'])
                : null;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE9ECEF)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Product Image Container (Stitch UI: Real Product Image with BlendMode.multiply)
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: (firstItemImg != null && firstItemImg.toString().trim().isNotEmpty)
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFF7F3F2),
                              BlendMode.multiply,
                            ),
                            child: Image.network(
                              firstItemImg.toString(),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const HugeIcon(
                                icon: HugeIcons.strokeRoundedRunningShoes,
                                color: AppColors.primary,
                                size: 36,
                              ),
                            ),
                          )
                        : const HugeIcon(
                            icon: HugeIcons.strokeRoundedRunningShoes,
                            color: AppColors.primary,
                            size: 36,
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Order Details & Track Button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItemName,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size: 42 | Color: Black',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EDEC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp ${_formatPrice(totalPrice)}',
                              style: AppTextStyles.price.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  context.push('/order-tracking/$docId'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Text(
                                'Track Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
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
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoggedIn && auth.user != null) {
          final user = auth.user!;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Stitch style)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedRunningShoes,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Profile',
                        style: AppTextStyles.h1.copyWith(fontSize: 24),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kixora Sneakers App v1.0.0 - Authentic Sneakers'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedSettings01,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.surfaceVariant, height: 1),

                // 2. Profile User Info Card (Stitch style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200, width: 2),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD1AyqKY5t3ekBa2z1q81wZ0H5mklHPeaJTFq0USDr7C46iEaPKRiR_AGLr7BgNmyKj4CRWSVVUHIySiMbF6xdHh-R1xJ546C342nPY-ARv3_uONIMY9XgwTKmjE7v5Iwt_hFFua4hJrecJXX2jxxKpTwNSbpELqmiE2qjLHeHDSNooUXeXWNYFPURV7hcNc9a7Qnt9lOkLbKfNu5iViSmwQ0tYKA95-3fKFWTr4x5Xs9i8efIp3clCU1B39ePL9U5nyjM',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showEditProfileDialog(context, auth, user.name),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedEdit02,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: AppTextStyles.h2.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+1 111 467 378 399',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.surfaceVariant, height: 1),

                // 3. Settings List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedUser,
                        title: 'Edit Profile',
                        onTap: () => _showEditProfileDialog(context, auth, user.name),
                      ),
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedLocation01,
                        title: 'Address',
                        onTap: () => context.push('/address'),
                      ),
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedNotification01,
                        title: 'Notification',
                        trailing: Switch.adaptive(
                          value: _isNotificationEnabled,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _isNotificationEnabled = val;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _isNotificationEnabled = !_isNotificationEnabled;
                          });
                        },
                      ),
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedEye,
                        title: 'Dark Mode',
                        trailing: Switch.adaptive(
                          value: _isDarkMode,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _isDarkMode = val;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        },
                      ),
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedLock,
                        title: 'Privacy Policy',
                        onTap: () => _showPrivacyPolicySheet(context),
                      ),
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedInformationCircle,
                        title: 'Help Center',
                        onTap: () => _showHelpCenterSheet(context),
                      ),
                      if (auth.isAdmin) ...[
                        _buildSettingsItem(
                          icon: HugeIcons.strokeRoundedSettings01,
                          title: 'Admin Dashboard',
                          onTap: () => context.push('/admin'),
                        ),
                      ],
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedLogout01,
                        title: 'Logout',
                        textColor: AppColors.error,
                        showChevron: false,
                        onTap: () => _showLogoutConfirmation(context, auth),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Guest / Not Logged In State
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedUserCircle,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Kixora Sneakers', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  'Login atau daftar akun untuk kemudahan memesan sepatu favoritmu',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogin01),
                    label: const Text('Masuk (Login)'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/register'),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01),
                    label: const Text('Daftar Akun Baru'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider auth, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Nama Profil', style: AppTextStyles.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ubah nama tampilan profil Anda di Kixora Sneakers.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context);
                  final success = await auth.updateProfileName(newName);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama profil berhasil diperbarui!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
              const SizedBox(height: 24),
              Text('Kebijakan Privasi Kixora Sneakers', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              Text(
                'Privasi Anda adalah prioritas kami. Di Kixora Sneakers, kami berkomitmen untuk melindungi informasi pribadi Anda.',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Kami hanya mengambil koordinat GPS perangkat Anda untuk keperluan pengiriman pesanan yang presisi dan melacak pengantaran kurir. Informasi Anda dienkripsi dengan aman dan tidak akan pernah dibagikan kepada pihak ketiga.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Saya Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpCenterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
              const SizedBox(height: 24),
              Text('Customer Care & Help Center', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              Text(
                'Butuh bantuan dengan pesanan sepatu Anda?',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const HugeIcon(icon: HugeIcons.strokeRoundedCall, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('WhatsApp CS: 0812-3456-7890', style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const HugeIcon(icon: HugeIcons.strokeRoundedMailAtSign01, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('Email: support@kixora.com', style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Semua produk yang dijual di aplikasi Kixora Sneakers dijamin 100% Original & Authentic langsung terintegrasi dengan KicksDB Catalog.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Konfirmasi Logout', style: AppTextStyles.h3),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun Anda?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await auth.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil keluar.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required List<List<dynamic>> icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    Color? textColor,
    bool showChevron = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              HugeIcon(
                icon: icon,
                color: textColor ?? AppColors.textPrimary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (trailing != null)
                trailing
              else if (showChevron)
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: Colors.grey,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHomePromoDetailSheet(BuildContext context, Map<String, dynamic> banner) {
    final colors = banner['colors'] as List<Color>;
    final voucherCode = banner['voucherCode'] as String;
    final discount = banner['discount'] as String;
    final title = banner['title'] as String;
    final subtitle = banner['subtitle'] as String;
    final image = banner['image'] as String;

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

              // Banner Card Preview
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.3),
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
                              discount,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
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
                              subtitle,
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
                              image,
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
                'Gunakan voucher diskon $discount ini untuk menghemat transaksi pembelian sepatu impian Anda.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildHomeTnCItem('Diskon $discount berlaku untuk semua katalog sepatu.'),
              _buildHomeTnCItem('Masukkan kode "$voucherCode" pada halaman pesanan.'),
              _buildHomeTnCItem('Voucher aktif & dapat langsung digunakan hari ini.'),
              const SizedBox(height: 20),

              // Voucher Code Container & Salin Button
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
                          voucherCode,
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
                        Clipboard.setData(ClipboardData(text: voucherCode));
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎟️ Kode Voucher "$voucherCode" berhasil disalin!'),
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

  Widget _buildHomeTnCItem(String text) {
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
