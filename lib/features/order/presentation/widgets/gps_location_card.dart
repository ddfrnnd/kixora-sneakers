import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';

class GpsLocationCard extends StatelessWidget {
  final String? addressTitle;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? error;

  const GpsLocationCard({
    super.key,
    this.addressTitle,
    this.addressText,
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLocation = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasLocation
              ? AppColors.primary.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
          width: hasLocation ? 1.5 : 1.0,
        ),
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
          // Header Row: Pin Icon & Title (Nama Alamat misal: Rumah)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Nama Alamat (misal: Rumah (Utama) / Kantor / Lokasi GPS)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (addressTitle != null && addressTitle!.isNotEmpty)
                          ? addressTitle!
                          : 'Rumah (Utama)',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alamat Terpilih',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
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
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Body: Alamat Lengkap di bawah Nama Alamat
          if (error != null)
            Text(
              error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                (addressText != null && addressText!.isNotEmpty)
                    ? addressText!
                    : 'Jl. Sudirman No. 45, Jakarta Selatan, 12190',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
