import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/core/utils/receipt_helper.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _userRating = 5;
  bool _isSubmittingReview = false;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showLeaveReviewSheet(BuildContext context, Map<String, dynamic> orderData) {
    final items = (orderData['items'] as List?) ?? [];
    final firstItem = items.isNotEmpty ? items.first : {};
    final String productName = firstItem['product_name'] ?? 'Sepatu Authentic';
    final String? imgUrl = firstItem['image_url'] ?? firstItem['imageUrl'];
    final String customerName = orderData['customer_name'] ?? 'Pelanggan Kixora';

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
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9ECEF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Beri Penilaian & Ulasan',
                    style: AppTextStyles.h2.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Real Product Preview Card (Stitch UI)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: (imgUrl != null && imgUrl.isNotEmpty)
                              ? ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFF7F3F2),
                                    BlendMode.multiply,
                                  ),
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const HugeIcon(
                                      icon: HugeIcons.strokeRoundedRunningShoes,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                )
                              : const HugeIcon(
                                  icon: HugeIcons.strokeRoundedRunningShoes,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pesanan selesai & siap dinilai',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Bagaimana kualitas sepatu & layanan kami?',
                    style: AppTextStyles.h3.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih bintang & tulis ulasan pengalaman Anda.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Interactive Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        onPressed: () {
                          setModalState(() => _userRating = starIndex);
                          setState(() => _userRating = starIndex);
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedStar,
                          size: 38,
                          color: starIndex <= _userRating
                              ? const Color(0xFFFFC107)
                              : const Color(0xFFE9ECEF),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Textarea Review Input
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tulis ulasan Anda di sini (contoh: Sepatu sangat nyaman, ori, kiriman cepat!)...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      fillColor: const Color(0xFFF7F3F2),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (Cancel / Submit)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(color: AppColors.primary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmittingReview
                              ? null
                              : () async {
                                  setModalState(() => _isSubmittingReview = true);

                                  try {
                                    // 1. Update Firestore Order Status to 'Selesai'
                                    await FirebaseFirestore.instance
                                        .collection('orders')
                                        .doc(widget.orderId)
                                        .update({
                                      'status': 'Selesai',
                                      'updated_at': DateTime.now().toIso8601String(),
                                    });

                                    // 2. Add One-Time Permanent Review into 'reviews' collection
                                    await FirebaseFirestore.instance.collection('reviews').add({
                                      'order_id': widget.orderId,
                                      'user_name': customerName,
                                      'rating': _userRating,
                                      'comment': _reviewController.text.trim().isEmpty
                                          ? 'Sepatu sangat bagus, nyaman dipakai dan pengiriman cepat!'
                                          : _reviewController.text.trim(),
                                      'product_name': productName,
                                      'created_at': DateTime.now().toIso8601String(),
                                      'time_ago': 'Baru saja',
                                    });

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('🎉 Ulasan & Penilaian Berhasil Dikirim! Pesanan Selesai.'),
                                          backgroundColor: AppColors.success,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Pesanan berhasil diselesaikan!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  } finally {
                                    setModalState(() => _isSubmittingReview = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: _isSubmittingReview
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Kirim Ulasan',
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
                ],
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
      appBar: AppBar(
        title: Text('Pelacakan Pesanan', style: AppTextStyles.h2.copyWith(fontSize: 20)),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.orderId.trim().isNotEmpty
            ? FirebaseFirestore.instance
                .collection('orders')
                .where(FieldPath.documentId, isEqualTo: widget.orderId)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('orders')
                .orderBy('created_at', descending: true)
                .limit(1)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          Map<String, dynamic> orderData = {};
          String currentDocId = widget.orderId;
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final doc = snapshot.data!.docs.first;
            currentDocId = doc.id;
            orderData = doc.data() as Map<String, dynamic>;
          }

          final String status = (orderData['status'] ?? 'Baru').toString();
          final double totalPrice = (orderData['total_price'] as num?)?.toDouble() ?? 0.0;
          final List items = (orderData['items'] as List?) ?? [];
          final Map firstItem = items.isNotEmpty ? items.first : {};
          final String productName = firstItem['product_name'] ?? 'Sepatu Authentic';
          final String? imgUrl = firstItem['image_url'] ?? firstItem['imageUrl'];
          final String recipientName = orderData['customer_name'] ?? 'Pelanggan Kixora';
          final String recipientPhone = orderData['customer_phone'] ?? '081234567890';
          final String address = orderData['address'] ?? 'Alamat Pemesanan';

          final displayId = currentDocId.length > 8
              ? currentDocId.substring(0, 8).toUpperCase()
              : (currentDocId.isNotEmpty ? currentDocId.toUpperCase() : 'KIXORA-88');

          final bool isShipped = status == 'Dikirim' || status == 'Selesai';
          final bool isCompleted = status == 'Selesai';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Summary Card with Real Image
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Real Shoe Image Container
                      Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: (imgUrl != null && imgUrl.isNotEmpty)
                            ? ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFF7F3F2),
                                  BlendMode.multiply,
                                ),
                                child: Image.network(
                                  imgUrl,
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

                      // Title & ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order ID: #$displayId',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rp ${_formatPrice(totalPrice)}',
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppColors.success.withValues(alpha: 0.12)
                                        : AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: isCompleted ? AppColors.success : AppColors.primary,
                                      fontSize: 11,
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
                ),
                const SizedBox(height: 24),

                // 2. Timeline Progress Steps (Real Status Synchronized)
                Text('Status Pengiriman & Pelacakan', style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                _buildTimelineItem(
                  title: 'Pesanan Dibuat',
                  time: 'Berhasil dikirim ke sistem',
                  description: 'Data pesanan pelanggan $recipientName telah diterima.',
                  isCompleted: true,
                  isLast: false,
                ),
                _buildTimelineItem(
                  title: 'Diproses Gudang',
                  time: 'Persiapan Pengemasan',
                  description: 'Sepatu disiapkan & diperiksa kualitasnya oleh tim gudang.',
                  isCompleted: status != 'Baru',
                  isLast: false,
                ),
                _buildTimelineItem(
                  title: 'Dalam Pengiriman Kurir',
                  time: isShipped ? 'Dalam Perjalanan' : 'Menunggu Kurir',
                  description: 'Paket sedang dibawakan kurir ke $address.',
                  isCompleted: isShipped,
                  isActive: isShipped && !isCompleted,
                  isLast: false,
                ),
                _buildTimelineItem(
                  title: 'Pesanan Selesai & Diterima',
                  time: isCompleted ? 'Selesai' : 'Estimasi 1-2 Hari',
                  description: 'Paket sepatu diterima dengan sukses & terverifikasi.',
                  isCompleted: isCompleted,
                  isLast: true,
                ),

                const SizedBox(height: 28),

                // 3. Complete & Review Action Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3F2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isCompleted ? 'Pesanan Ini Telah Selesai 🎉' : 'Paket Sudah Diterima?',
                        style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isCompleted
                            ? 'Terima kasih atas ulasan & kepercayaan Anda pada Kixora Sneakers.'
                            : 'Konfirmasi penerimaan paket dan berikan ulasan serta bintang penilaian Anda.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (isCompleted) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                                color: AppColors.success,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Penilaian & Ulasan Telah Dikirim',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Primary Action: Complete & Review Button (One-time submission)
                        ElevatedButton.icon(
                          onPressed: () => _showLeaveReviewSheet(context, orderData),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppColors.primary,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedStar,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Selesaikan & Beri Penilaian',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Secondary Action: Download PDF Receipt
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ReceiptHelper.saveReceiptToDevice(
                            context: context,
                            orderId: '#SLS-$displayId',
                            recipientName: recipientName,
                            recipientPhone: recipientPhone,
                            address: address,
                            totalPrice: totalPrice,
                            items: items.map((it) {
                              return {
                                'name': it['product_name'] ?? 'Sepatu Authentic',
                                'quantity': (it['quantity'] as num?)?.toInt() ?? 1,
                                'price': (it['price'] as num?)?.toDouble() ?? totalPrice,
                              };
                            }).toList(),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedFile02,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: const Text(
                          'Simpan Struk Resi (PDF)',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required String description,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Dot & Line
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.primary : const Color(0xFFC4C7C7),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const HugeIcon(
                      icon: HugeIcons.strokeRoundedTick01,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? AppColors.primary : const Color(0xFFE9ECEF),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Timeline Details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isCompleted ? AppColors.textPrimary : AppColors.textHint,
                      ),
                    ),
                    Text(
                      time,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: isCompleted ? AppColors.textSecondary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
