import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/core/utils/receipt_helper.dart';
import 'package:fashion_ecommerce/features/admin/presentation/providers/admin_provider.dart';
import 'package:fashion_ecommerce/features/admin/presentation/widgets/admin_analytics_widget.dart';
import 'package:fashion_ecommerce/features/admin/presentation/widgets/order_status_badge.dart';
import 'package:fashion_ecommerce/features/auth/presentation/providers/auth_provider.dart';
import 'package:fashion_ecommerce/features/product/presentation/providers/product_provider.dart';
import 'package:fashion_ecommerce/shared/widgets/loading_indicator.dart';
import 'package:fashion_ecommerce/shared/widgets/error_widget.dart';
import 'package:fashion_ecommerce/shared/widgets/empty_state_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  String _selectedOrderStatus = 'Semua';
  String _selectedProductCategory = 'Semua';

  static const List<String> _orderStatuses = ['Semua', 'Baru', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'];
  static const List<String> _productCategories = ['Semua', 'Nike', 'Adidas', 'Jordan', 'Puma', 'Converse', 'Vans', 'New Balance', 'Reebok', 'Sneakers', 'Running', 'Casual', 'Formal'];

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(feature),
        content: const Text('Fitur ini sedang dalam pengembangan dan akan segera tersedia.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(c),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchOrders();
    });
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _getAppBarTitle(_currentIndex),
          style: AppTextStyles.h2.copyWith(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AdminProvider>().fetchOrders();
            },
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, color: AppColors.textPrimary),
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthProvider>().logout();
                context.go('/home');
              }
            },
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, color: AppColors.textPrimary),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Logout Admin'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.isLoading) {
            return const LoadingIndicator(message: 'Memuat data admin...');
          }

          if (admin.error != null) {
            return AppErrorWidget(
              message: admin.error!,
              onRetry: () => admin.fetchOrders(),
            );
          }

          return IndexedStack(
            index: _currentIndex,
            children: [
              // TAB 0: DASHBOARD (Ringkasan Eksekutif & KPI)
              _buildDashboardTab(admin),

              // TAB 1: PRODUCT (Manajemen Katalog Sepatu)
              _buildProductTab(),

              // TAB 2: REPORT (Laporan Keuangan & Grafik fl_chart)
              _buildReportTab(admin),

              // TAB 3: ORDER (Manajemen Transaksi & Status Tracking)
              _buildOrderTab(admin),

              // TAB 4: PROFILE (Profil Admin & Setting Toko)
              _buildProfileTab(),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedDashboardSquare01),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedDashboardSquare01, color: AppColors.primary),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, color: AppColors.primary),
              label: 'Product',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics01),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics01, color: AppColors.primary),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedReceiptText),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedReceiptText, color: AppColors.primary),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedUser),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Ringkasan Toko';
      case 1:
        return 'Katalog Produk';
      case 2:
        return 'Laporan & Analitik';
      case 3:
        return 'Manajemen Pesanan';
      case 4:
        return 'Profil Admin';
      default:
        return 'Admin Panel';
    }
  }

  // --- TAB 0: DASHBOARD ---
  Widget _buildDashboardTab(AdminProvider admin) {
    final double totalRevenue = admin.orders.fold(0.0, (acc, o) => acc + o.totalPrice);
    final int pendingOrders = admin.orders.where((o) => o.status == 'Baru' || o.status == 'Diproses').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat datang kembali, Admin.',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pendingOrders > 0
                            ? 'Ada $pendingOrders pesanan yang perlu segera diproses.'
                            : 'Semua pesanan sudah tertangani. Toko berjalan lancar.',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedStore01, color: Color(0xFF4ADE80), size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Executive Summary Stats
          Row(
            children: [
              Expanded(
                child: _buildSummaryMiniCard(
                  title: 'Omzet Total',
                  value: 'Rp ${_formatPrice(totalRevenue)}',
                  icon: HugeIcons.strokeRoundedMoney01,
                  color: const Color(0xFF047857),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryMiniCard(
                  title: 'Pesanan Aktif',
                  value: '$pendingOrders Pesanan',
                  icon: HugeIcons.strokeRoundedPackage01,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Action Shortcuts
          Text('Pintasan Cepat', style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildShortcutButton(
                  title: 'Tambah Produk',
                  icon: HugeIcons.strokeRoundedAdd01,
                  color: AppColors.primary,
                  onTap: () => context.push('/admin/add-product'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShortcutButton(
                  title: 'Lihat Report',
                  icon: HugeIcons.strokeRoundedAnalytics01,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Orders Header & Short List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pesanan Terbaru', style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 3),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          admin.orders.isEmpty
              ? const EmptyStateWidget(
                  title: 'Belum Ada Pesanan',
                  subtitle: 'Pesanan dari pelanggan akan muncul di sini setelah mereka checkout.',
                  icon: HugeIcons.strokeRoundedReceiptText,
                )
              : Column(
                  children: admin.orders.take(3).map((order) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => context.push('/admin/orders/${order.id}'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const HugeIcon(icon: HugeIcons.strokeRoundedShoppingBag01, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(order.customerName, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                    Text('#${order.id} • ${_formatDate(order.createdAt)}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              OrderStatusBadge(status: order.status),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // --- TAB 1: PRODUCT ---
  Widget _buildProductTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator(message: 'Memuat produk sepatu...');
        }

        final allDocs = snapshot.data?.docs ?? [];

        // Apply category filter
        final docs = _selectedProductCategory == 'Semua'
            ? allDocs
            : allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final cat = (data['category'] ?? '').toString().toLowerCase();
                return cat.contains(_selectedProductCategory.toLowerCase()) ||
                    _selectedProductCategory.toLowerCase().contains(cat);
              }).toList();

        return Stack(
          children: [
            Column(
              children: [
                // Category filter chips
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _productCategories.map((cat) {
                        final isSelected = _selectedProductCategory == cat;
                        final count = cat == 'Semua'
                            ? allDocs.length
                            : allDocs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final dcat = (data['category'] ?? '').toString().toLowerCase();
                                return dcat.contains(cat.toLowerCase()) || cat.toLowerCase().contains(dcat);
                              }).length;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedProductCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (count > 0) ...[const SizedBox(width: 6), Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text('$count', style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                                  )],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Product list
                Expanded(
                  child: docs.isEmpty
                      ? EmptyStateWidget(
                          title: _selectedProductCategory == 'Semua' ? 'Katalog Masih Kosong' : 'Tidak Ada Produk "$_selectedProductCategory"',
                          subtitle: _selectedProductCategory == 'Semua'
                              ? 'Mulai tambahkan produk sepatu agar pelanggan dapat berbelanja.'
                              : 'Belum ada produk dengan brand atau kategori ini.',
                          icon: HugeIcons.strokeRoundedRunningShoes,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final docId = docs[index].id;
                            final String name = data['name'] ?? 'Sepatu Authentic';
                            final double price = (data['price'] as num?)?.toDouble() ?? 0.0;
                            final String category = data['category'] ?? 'Sneakers';
                            final String? imageUrl = data['image_url'];

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F3F2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: imageUrl != null && imageUrl.isNotEmpty
                                        ? ColorFiltered(
                                            colorFilter: const ColorFilter.mode(Color(0xFFF7F3F2), BlendMode.multiply),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (c, e, s) => const HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, color: AppColors.primary),
                                            ),
                                          )
                                        : const HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(category, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                        const SizedBox(height: 4),
                                        Text('Rp ${_formatPrice(price)}', style: AppTextStyles.priceSmall.copyWith(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: AppColors.primary, size: 20),
                                        onPressed: () {
                                          context.push('/admin/add-product', extra: {'productId': docId, 'initialData': data});
                                        },
                                        tooltip: 'Edit Produk',
                                      ),
                                      IconButton(
                                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: AppColors.error, size: 20),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (c) => AlertDialog(
                                              title: const Text('Hapus Produk'),
                                              content: Text('Apakah Anda yakin ingin menghapus produk "$name"?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(c, true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await FirebaseFirestore.instance.collection('products').doc(docId).delete();
                                            if (context.mounted) {
                                              await context.read<ProductProvider>().fetchProducts();
                                            }
                                          }
                                        },
                                        tooltip: 'Hapus Produk',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            // Floating Add Product Button
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/admin/add-product'),
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, color: Colors.white),
                label: const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  // --- TAB 2: REPORT ---
  Widget _buildReportTab(AdminProvider admin) {
    final double totalRevenue = admin.orders.fold(0.0, (acc, o) => acc + o.totalPrice);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header & Print PDF Button Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Laporan Rekap Penjualan', style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${admin.orders.length} transaksi · Total Rp ${_formatPrice(totalRevenue)}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ReceiptHelper.generateSalesReport(
                      context: context,
                      orders: admin.orders,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedPrinter, color: Colors.white, size: 16),
                  label: const Text('Cetak PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Analytics Charts (fl_chart)
          AdminAnalyticsWidget(orders: admin.orders),
        ],
      ),
    );
  }

  // --- TAB 3: ORDER ---
  Widget _buildOrderTab(AdminProvider admin) {
    // Filter orders by selected status
    final filteredOrders = _selectedOrderStatus == 'Semua'
        ? admin.orders
        : admin.orders.where((o) => o.status == _selectedOrderStatus).toList();

    return Column(
      children: [
        // Status Filter Tabs
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _orderStatuses.map((status) {
                final isSelected = _selectedOrderStatus == status;
                final count = status == 'Semua'
                    ? admin.orders.length
                    : admin.orders.where((o) => o.status == status).length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedOrderStatus = status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          if (count > 0) ...
                          [
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Order List
        Expanded(
          child: filteredOrders.isEmpty
              ? EmptyStateWidget(
                  title: _selectedOrderStatus == 'Semua'
                      ? 'Belum Ada Pesanan'
                      : 'Tidak Ada Pesanan "$_selectedOrderStatus"',
                  subtitle: _selectedOrderStatus == 'Semua'
                      ? 'Pesanan dari pelanggan akan tampil di sini setelah mereka menyelesaikan checkout.'
                      : 'Semua pesanan dengan status ini sudah tertangani.',
                  icon: HugeIcons.strokeRoundedReceiptText,
                )
              : RefreshIndicator(
                  onRefresh: () => admin.fetchOrders(),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return InkWell(
                        onTap: () => context.push('/admin/orders/${order.id}'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '#${order.id}',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  OrderStatusBadge(status: order.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.customerName,
                                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const HugeIcon(icon: HugeIcons.strokeRoundedCall, size: 14, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(order.customerPhone, style: AppTextStyles.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDate(order.createdAt), style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                  Text('Rp ${_formatPrice(order.totalPrice)}', style: AppTextStyles.priceSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // --- TAB 4: PROFILE ---
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primary,
                  child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text('Admin Kixora', style: AppTextStyles.h2.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('admin@kixora.com', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('Administrator', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Setting Options List
          _buildProfileTile(title: 'Pengaturan Toko', icon: HugeIcons.strokeRoundedStore01, onTap: () => _showComingSoon(context, 'Pengaturan Toko')),
          _buildProfileTile(title: 'Manajemen Akses Staff', icon: HugeIcons.strokeRoundedUserGroup, onTap: () => _showComingSoon(context, 'Manajemen Akses Staff')),
          _buildProfileTile(title: 'Keamanan Akun', icon: HugeIcons.strokeRoundedLock, onTap: () => _showComingSoon(context, 'Keamanan Akun')),
          _buildProfileTile(title: 'Kebijakan & Ketentuan', icon: HugeIcons.strokeRoundedDocumentCode, onTap: () => _showComingSoon(context, 'Kebijakan & Ketentuan')),
          const SizedBox(height: 16),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: Colors.white, size: 20),
            label: const Text('Keluar dari Panel Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMiniCard({required String title, required String value, required dynamic icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: HugeIcon(icon: icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton({required String title, required dynamic icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({required String title, required dynamic icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        leading: HugeIcon(icon: icon, color: AppColors.primary, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.textHint, size: 18),
      ),
    );
  }
}
