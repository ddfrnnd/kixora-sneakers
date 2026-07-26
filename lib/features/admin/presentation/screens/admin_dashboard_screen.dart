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
        return 'Dashboard Admin';
      case 1:
        return 'Katalog Produk Sepatu';
      case 2:
        return 'Laporan & Analitik Business';
      case 3:
        return 'Manajemen Pesanan';
      case 4:
        return 'Profil & Pengaturan Admin';
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
                        'Selamat Datang, Admin! 👋',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Toko Kixora Sneakers berjalan lancar. Ada $pendingOrders pesanan butuh respon.',
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
          Text('Aksi Cepat Admin', style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
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
                child: const Text('Lihat Semua ➔'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          admin.orders.isEmpty
              ? const EmptyStateWidget(
                  title: 'Belum Ada Pesanan',
                  subtitle: 'Pesanan baru akan muncul di sini',
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

        final docs = snapshot.data?.docs ?? [];

        return Stack(
          children: [
            docs.isEmpty
                ? const EmptyStateWidget(
                    title: 'Belum Ada Produk',
                    subtitle: 'Tambahkan sepatu baru ke toko Anda',
                    icon: HugeIcons.strokeRoundedRunningShoes,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
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
                            IconButton(
                              icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: AppColors.error, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Hapus Produk'),
                                    content: Text('Yakin ingin menghapus sepatu "$name"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                                      ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Hapus')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance.collection('products').doc(docId).delete();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

            // Floating Add Product Button
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/admin/add-product'),
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, color: Colors.white),
                label: const Text('Tambah Sepatu Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      Text('Cetak dokumen PDF pertanggungjawaban resmi', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ReceiptHelper.saveReceiptToDevice(
                      context: context,
                      orderId: '#REKAP-KIXORA',
                      recipientName: 'Pemilik Toko Kixora',
                      recipientPhone: '08123456789',
                      address: 'Laporan Rekapitulasi Penjualan Resmi',
                      totalPrice: totalRevenue,
                      items: admin.orders.expand((o) => o.items).map((it) {
                        return {
                          'name': it.productName,
                          'quantity': it.quantity,
                          'price': it.price,
                        };
                      }).toList(),
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
    if (admin.orders.isEmpty) {
      return const EmptyStateWidget(
        title: 'Belum Ada Pesanan',
        subtitle: 'Pesanan pelanggan akan muncul di sini',
        icon: HugeIcons.strokeRoundedReceiptText,
      );
    }

    return RefreshIndicator(
      onRefresh: () => admin.fetchOrders(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: admin.orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = admin.orders[index];
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
                  child: const Text('Super Administrator', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Setting Options List
          _buildProfileTile(title: 'Pengaturan Toko Kixora', icon: HugeIcons.strokeRoundedStore01, onTap: () {}),
          _buildProfileTile(title: 'Kelola Hak Akses Staff', icon: HugeIcons.strokeRoundedUserGroup, onTap: () {}),
          _buildProfileTile(title: 'Keamanan & Ganti Password', icon: HugeIcons.strokeRoundedLock, onTap: () {}),
          _buildProfileTile(title: 'Kebijakan Privasi & Ketentuan', icon: HugeIcons.strokeRoundedDocumentCode, onTap: () {}),
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
            label: const Text('Keluar Akun Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
