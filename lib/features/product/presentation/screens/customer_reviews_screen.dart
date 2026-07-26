import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';

class ReviewItemData {
  final String name;
  final String avatarUrl;
  final int rating;
  final String comment;
  final int likes;
  final String timeAgo;

  ReviewItemData({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.likes,
    required this.timeAgo,
  });
}

class CustomerReviewsScreen extends StatefulWidget {
  const CustomerReviewsScreen({super.key});

  @override
  State<CustomerReviewsScreen> createState() => _CustomerReviewsScreenState();
}

class _CustomerReviewsScreenState extends State<CustomerReviewsScreen> {
  String _selectedRatingFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        List<ReviewItemData> reviewsList = [];

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            reviewsList.add(
              ReviewItemData(
                name: data['user_name'] ?? 'Pelanggan SoleStep',
                avatarUrl: data['avatar_url'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                rating: (data['rating'] as num?)?.toInt() ?? 5,
                comment: data['comment'] ?? 'Ulasan produk sepatu yang sangat memuaskan!',
                likes: (data['likes'] as num?)?.toInt() ?? 12,
                timeAgo: data['time_ago'] ?? 'Baru saja',
              ),
            );
          }
        }

        final filteredReviews = reviewsList.where((review) {
          if (_selectedRatingFilter == 'All') return true;
          final targetRating = int.tryParse(_selectedRatingFilter);
          return review.rating == targetRating;
        }).toList();

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
              'Ulasan Pelanggan (${reviewsList.length})',
              style: AppTextStyles.h2.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              // Rating Filter Chips Bar
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: ['All', '5', '4', '3', '2'].map((filter) {
                    final isSelected = _selectedRatingFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: isSelected
                            ? const Icon(Icons.star, size: 14, color: Colors.white)
                            : const Icon(Icons.star, size: 14, color: AppColors.primary),
                        label: Text(
                          filter == 'All' ? 'All' : '$filter Stars',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRatingFilter = filter);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Reviews List Streamed 100% from Firestore Database
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : filteredReviews.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const HugeIcon(
                                  icon: HugeIcons.strokeRoundedStar,
                                  color: AppColors.textHint,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada ulasan untuk filter ini.',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: filteredReviews.length,
                            separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFE9ECEF)),
                            itemBuilder: (context, index) {
                              final review = filteredReviews[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(review.avatarUrl),
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(review.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                            Text(review.timeAgo, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),

                                      // Rating Stars Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, size: 14, color: AppColors.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              review.rating.toString(),
                                              style: AppTextStyles.caption.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    review.comment,
                                    style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                                  ),
                                ],
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
