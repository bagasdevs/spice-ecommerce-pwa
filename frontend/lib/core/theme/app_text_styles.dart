import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Headline Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Title Text Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label Text Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button Text Styles
  static const TextStyle button = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textInverse,
    height: 1.2,
  );

  // Caption Text Styles
  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Overline Text Style
  static const TextStyle overline = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Price Text Styles
  static const TextStyle price = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.2,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.2,
  );

  // Status Text Styles
  static const TextStyle statusSuccess = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
    height: 1.2,
  );

  static const TextStyle statusWarning = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.warning,
    height: 1.2,
  );

  static const TextStyle statusError = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    height: 1.2,
  );

  static const TextStyle discount = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
    height: 1.2,
  );

  // Form Text Styles

  static const TextStyle inputText = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle errorText = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.3,
  );

  // Navigation Text Styles
  static const TextStyle tabLabel = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle navTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    height: 1.2,
  );

  // Card Text Styles
  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // List Text Styles
  static const TextStyle chip = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle listSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Snackbar Text Style
  static const TextStyle snackbar = TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textInverse,
    height: 1.3,
  );

  // Link Text Style
  static const TextStyle link = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.3,
    decoration: TextDecoration.underline,
  );

  // Helper method to get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  // Helper method to get text style with custom size
  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }

  // Helper method to get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight fontWeight) {
    return style.copyWith(fontWeight: fontWeight);
  }
}
