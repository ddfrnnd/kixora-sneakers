import 'package:flutter/material.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:hugeicons/hugeicons.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  Color get _backgroundColor {
    switch (status) {
      case 'Baru':
        return AppColors.statusBaru.withValues(alpha: 0.1);
      case 'Diproses':
        return AppColors.statusDiproses.withValues(alpha: 0.1);
      case 'Selesai':
        return AppColors.statusSelesai.withValues(alpha: 0.1);
      default:
        return AppColors.shimmerBase;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'Baru':
        return AppColors.statusBaru;
      case 'Diproses':
        return AppColors.statusDiproses;
      case 'Selesai':
        return AppColors.statusSelesai;
      default:
        return AppColors.textSecondary;
    }
  }

  List<List<dynamic>> get _icon {
    switch (status) {
      case 'Baru':
        return HugeIcons.strokeRoundedNewReleases;
      case 'Diproses':
        return HugeIcons.strokeRoundedRefresh;
      case 'Selesai':
        return HugeIcons.strokeRoundedCheckmarkCircle01;
      default:
        return HugeIcons.strokeRoundedInformationCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: _icon, size: 14, color: _textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
