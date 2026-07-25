import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';

class GpsLocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? addressText;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const GpsLocationCard({
    super.key,
    this.latitude,
    this.longitude,
    this.addressText,
    this.isLoading = false,
    this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLocation = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasLocation
              ? AppColors.primary.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
          width: hasLocation ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
                  color: hasLocation ? AppColors.primary : AppColors.textHint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lokasi GPS Alamat', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      hasLocation ? 'Lokasi terhubung dengan peta' : 'Belum memilih lokasi',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
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
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedGps01, color: AppColors.primary),
                  tooltip: 'Deteksi ulang GPS',
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (error != null)
            Text(
              error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            )
          else if (hasLocation)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedPinLocation01,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      (addressText != null && addressText!.isNotEmpty)
                          ? addressText!
                          : 'Alamat terhubung presisi dengan titik peta GPS',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Tekan tombol GPS di samping untuk mendeteksi alamat Anda otomatis',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}
