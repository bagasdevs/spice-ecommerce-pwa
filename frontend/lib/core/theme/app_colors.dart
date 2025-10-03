import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Green theme for nature/agriculture
  static const Color primary = Color(0xFF2E7D32); // Forest Green
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  // Secondary Colors - Warm earth tones
  static const Color secondary = Color(0xFFFF8F00); // Orange
  static const Color secondaryLight = Color(0xFFFFC046);
  static const Color secondaryDark = Color(0xFFC56000);

  // Accent Colors
  static const Color accent = Color(0xFF4CAF50); // Light Green
  static const Color accentLight = Color(0xFF80E27E);
  static const Color accentDark = Color(0xFF087F23);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Utility Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1F000000);
  static const Color overlay = Color(0x66000000);
  static const Color disabled = Color(0xFFBDBDBD);

  // Spice-specific Colors
  static const Color spiceYellow = Color(0xFFFFEB3B); // Turmeric
  static const Color spiceRed = Color(0xFFD32F2F); // Chili
  static const Color spiceBrown = Color(0xFF8D6E63); // Cinnamon
  static const Color spiceGreen = Color(0xFF689F38); // Herbs

  // Quality Grade Colors
  static const Color gradeA = Color(0xFFFFD700); // Gold
  static const Color gradeB = Color(0xFFC0C0C0); // Silver
  static const Color gradeC = Color(0xFFCD7F32); // Bronze

  // Transaction Status Colors
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusPaid = Color(0xFF4CAF50);
  static const Color statusProcessing = Color(0xFF2196F3);
  static const Color statusShipped = Color(0xFF9C27B0);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);
  static const Color statusRefunded = Color(0xFF607D8B);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2E7D32),
    Color(0xFFFF8F00),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
    Color(0xFF795548),
  ];

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkDivider = Color(0xFF373737);
}
