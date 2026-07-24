import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _baseStyle => GoogleFonts.urbanist(color: AppColors.textPrimary);

  // Headings (Urbanist)
  static TextStyle get h1 => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.3,
      );

  static TextStyle get h2 => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      );

  static TextStyle get h3 => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get h4 => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body (Urbanist)
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Labels (Urbanist)
  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelMedium => GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Price (Urbanist)
  static TextStyle get price => GoogleFonts.urbanist(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle get priceSmall => GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  // Button (Urbanist)
  static TextStyle get button => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnPrimary,
      );
}
