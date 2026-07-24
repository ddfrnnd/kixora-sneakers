import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';

class GpsLocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const GpsLocationCard({
    super.key,
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: latitude != null
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.shimmerBase,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: latitude != null ? AppColors.success : AppColors.textHint,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text('Lokasi GPS', style: AppTextStyles.labelLarge),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                IconButton(
                  onPressed: onRefresh,
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, color: AppColors.primary),
                  tooltip: 'Refresh lokasi',
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (error != null)
            Text(
              error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            )
          else if (latitude != null && longitude != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoordRow('Latitude', latitude!.toStringAsFixed(6)),
                const SizedBox(height: 4),
                _buildCoordRow('Longitude', longitude!.toStringAsFixed(6)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Lokasi berhasil diambil',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Text(
              'Tap refresh untuk mengambil lokasi GPS',
              style: AppTextStyles.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildCoordRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: AppTextStyles.caption),
        ),
        Text(': ', style: AppTextStyles.caption),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
