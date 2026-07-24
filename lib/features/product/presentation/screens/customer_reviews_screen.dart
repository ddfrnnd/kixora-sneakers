import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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

  final List<ReviewItemData> _allReviews = [
    ReviewItemData(
      name: 'Darlene Robertson',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvzNAQ2xRzc-iekDdeuq9BV4EnU_5ScdmSci1UOloXZnqkP_p4_PXnQ08Vj5FZDOhIhrYqksph5uUs8c_vUnE_dcK3D8QyMtEYjxz_jSEFBkxmgXCtGgjwJwcRJe5Txd40EK2Aq6GqzWFFRCFwIc940NuCtyIheUttKEQA-uBAkEfWfQw0R59AEGBlyKGRDkv6LpU1e6AfsQzR_iIT46LaAAUiBkpQIE83lXmX9iH8Zy3B9D7tXp3J8w',
      rating: 5,
      comment: 'The item is very good, my son likes it very much and wearing it every day 💯💯💯',
      likes: 729,
      timeAgo: '6 days ago',
    ),
    ReviewItemData(
      name: 'Jane Cooper',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAlliD8qnkuNep47XdGn5jlUnYD5V0zz1g5hIuhhUNfACsVr28NbBXkZ9EyyagUKq7ek7pg5w4qEwAjJi77TON36EZDbqm339-G8ScFfG4lmB28NvVtNRRB6McdVXxk96ZTO-hpxTf6SDswb0UALkxMNknS_Vt1RQlGcVQqyoIN5d1hO6Ieieh_HW4X9KgECKmN_DMaFHhM4IrLDLOGY4eSzLkKSItSJ9vKoyXR4sU45avc1xnwTbXfWA',
      rating: 4,
      comment: 'The seller is very fast in sending packet, I just bought it and the item arrived in just 1 day! 👍👍',
      likes: 625,
      timeAgo: '6 days ago',
    ),
    ReviewItemData(
      name: 'Jenny Wilson',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC1yDpqswZqXBnnPfkSSeZXVRVh207A3jSgtnj0S7iZPD_rX5LwkCrSzGZZirdTLZGVPy5KNm1x4y1qR4A2mpNJbgdrCFzi3rbG9aGsexHDldDJX6O0-nn72mq5pgvDvr5Twkzmth8NrwHwkMVG4FfZ8nqNDd0jG7in2m7xGsRQ4bNA_FHckvwmbEgD-tyjEsV4PdApRQG7E-JT8Zzgi99SyBxsv9-v4IpOXX_wZrroRWOe7aExLfe1mg',
      rating: 5,
      comment: 'I just bought it and the sneakers is really good! I highly recommend it! 😄😄',
      likes: 578,
      timeAgo: '6 days ago',
    ),
    ReviewItemData(
      name: 'Marvin McKinney',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAH6jgUFeiqSANNJfBcuJEC7s7jwBeuR4cyja1jU0eBCBNFKP4ZR0Oil_oXP_dRqlfubjicD6o0DoeAzNNp2tWe4xJXHm1m1cX5GxEAbjZTQ13LJJ4OeqIcb49JhSln-6ggL5TUIApwZtQLyaYLgzLiJPHwmp4ezkL4nJ0hANiOzrS2HyCxbzC5lA2EmTr3rSmuIAXUQykzJZ09Rlc_PObsEEaWtJPdWiMnyF2oAkuQKV4IJr-DghRU0Q',
      rating: 5,
      comment: 'Super authentic quality! The cushioning and grip are top tier for basketball and casual daily walk.',
      likes: 347,
      timeAgo: '2 weeks ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        List<ReviewItemData> combined = List.from(_allReviews);

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            combined.insert(
              0,
              ReviewItemData(
                name: data['user_name'] ?? 'Pelanggan SoleStep',
                avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                rating: (data['rating'] as num?)?.toInt() ?? 5,
                comment: data['comment'] ?? 'Ulasan produk sepatu yang luar biasa!',
                likes: 12,
                timeAgo: data['time_ago'] ?? 'Baru saja',
              ),
            );
          }
        }

        final filteredReviews = combined.where((review) {
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
              '4.8 (${combined.length} Ulasan)',
              style: AppTextStyles.h2.copyWith(fontSize: 18),
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
                            fontSize: 13,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRatingFilter = filter);
                          }
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Reviews List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredReviews.length,
                  separatorBuilder: (context, index) => const Divider(height: 32, color: Color(0xFFE9ECEF)),
                  itemBuilder: (context, index) {
                    return _buildReviewCard(filteredReviews[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewItemData review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(review.avatarUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                review.name,
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${review.rating}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review.comment,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.favorite_border, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              '${review.likes}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              review.timeAgo,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
