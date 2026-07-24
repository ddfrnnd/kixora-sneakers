import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Theme: Minimalist Black & White / High Contrast (SoleStep Design System)
  static const Color primary = Color(0xFF111111);        // Main dark surface / Primary CTA
  static const Color primaryLight = Color(0xFF333333);   // Charcoal
  static const Color primaryDark = Color(0xFF000000);    // Pure Black

  // Secondary
  static const Color secondary = Color(0xFF6C757D);     // Cool grey
  static const Color secondaryLight = Color(0xFFF8F9FA); // Container background
  static const Color accent = Color(0xFFE53935);        // Accent Red / Sale badge

  // Neutral
  static const Color background = Color(0xFFFFFFFF);    // Clean White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Light Grey container
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF111111);   // High contrast dark
  static const Color textSecondary = Color(0xFF6C757D); // Subtitle / Grey text
  static const Color textHint = Color(0xFF9E9E9E);      // Placeholder
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF1976D2);

  // Order Status Badge Colors
  static const Color statusBaru = Color(0xFF1976D2);
  static const Color statusDiproses = Color(0xFFFF9800);
  static const Color statusSelesai = Color(0xFF2E7D32);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Shadow
  static const Color shadow = Color(0x0F000000);
}
