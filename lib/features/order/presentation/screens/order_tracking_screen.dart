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
    final customerName = orderData['customer_name'] ?? 'Pelanggan Kixora';
    final List items = (orderData['items'] as List?) ?? [];
    int selectedProductIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final Map currentProduct = items.isNotEmpty ? items[selectedProductIndex] : {};
            final String productName = currentProduct['product_name'] ?? 'Sepatu Authentic';
            final String? productId = currentProduct['product_id'] ?? currentProduct['id'];
            final String? imgUrl = currentProduct['image_url'] ?? currentProduct['imageUrl'];

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E2E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // If order has multiple products, allow selecting product to review
                  if (items.length > 1) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pilih Produk yang Diulas:',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedProductIndex,
                          isExpanded: true,
                          items: List.generate(items.length, (idx) {
                            final item = items[idx];
                            return DropdownMenuItem<int>(
                              value: idx,
                              child: Text(
                                item['product_name'] ?? 'Sepatu ${idx + 1}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedProductIndex = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Real Product Preview Card
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
                  const SizedBox(height: 20),

                  // Action Button: Kirim Ulasan
                  ElevatedButton(
                    onPressed: _isSubmittingReview
                        ? null
                        : () async {
                            setModalState(() => _isSubmittingReview = true);

                            try {
                              // Save Permanent Review for the selected product
                              await FirebaseFirestore.instance.collection('reviews').add({
                                'order_id': widget.orderId,
                                'product_id': productId ?? '',
                                'product_name': productName,
                                'user_name': customerName,
                                'rating': _userRating,
                                'comment': _reviewController.text.trim().isEmpty
                                    ? 'Sepatu sangat bagus, nyaman dipakai dan pengiriman cepat!'
                                    : _reviewController.text.trim(),
                                'created_at': DateTime.now().toIso8601String(),
                                'time_ago': 'Baru saja',
                              });

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ulasan berhasil dikirim. Terima kasih!'),
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
                                    content: Text('Gagal mengirim ulasan.'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            } finally {
                              setModalState(() => _isSubmittingReview = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
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
                              fontSize: 15,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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
                // Single Unified Order & Products Card
                Container(
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Order ID & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pesanan #${displayId}',
                                style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${items.length} Barang Dipesan',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
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
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Products List
                      ...items.map((it) {
                        final itName = it['product_name'] ?? 'Sepatu Authentic';
                        final itPrice = (it['price'] as num?)?.toDouble() ?? 0.0;
                        final itQty = (it['quantity'] as num?)?.toInt() ?? 1;
                        final itImg = it['image_url'] ?? it['imageUrl'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F3F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: (itImg != null && itImg.toString().isNotEmpty)
                                    ? ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFF7F3F2),
                                          BlendMode.multiply,
                                        ),
                                        child: Image.network(
                                          itImg.toString(),
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const HugeIcon(
                                            icon: HugeIcons.strokeRoundedRunningShoes,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                      )
                                    : const HugeIcon(
                                        icon: HugeIcons.strokeRoundedRunningShoes,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itName,
                                      style: AppTextStyles.labelLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Jumlah: $itQty x Rp ${_formatPrice(itPrice)}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice(itPrice * itQty)}',
                                style: AppTextStyles.price.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Footer Row: Total Payment
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(totalPrice)}',
                            style: AppTextStyles.price.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
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
                        isCompleted ? 'Pesanan Selesai' : 'Paket Sudah Diterima?',
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
                        ElevatedButton(
                          onPressed: () => _showLeaveReviewSheet(context, orderData),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppColors.primary,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Text(
                            'Beri Ulasan Produk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(currentDocId)
                                .update({
                              'status': 'Selesai',
                              'updated_at': DateTime.now().toIso8601String(),
                            });
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Pesanan berhasil diselesaikan!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppColors.primary,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Text(
                            'Konfirmasi Pesanan Diterima',
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
                      OutlinedButton(
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
                        child: const Text(
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
