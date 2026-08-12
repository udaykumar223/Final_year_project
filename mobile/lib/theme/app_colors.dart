import 'package:flutter/material.dart';

/// SmartCrop AI — Color Palette
/// Nature + AI + Simplicity
class AppColors {
  AppColors._();

  // Primary — Deep Forest Green
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF0D3B13);

  // Secondary — Fresh Leaf Green
  static const Color secondary = Color(0xFF66BB6A);
  static const Color secondaryLight = Color(0xFF81C784);

  // Background
  static const Color background = Color(0xFFFAFAF5);
  static const Color backgroundDark = Color(0xFFF0F0E8);

  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F0);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Neutral
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  // Crop-specific accent colors
  static const Color bananaAccent = Color(0xFFFFD700);
  static const Color groundnutAccent = Color(0xFFCD853F);
  static const Color radishAccent = Color(0xFFFF6B6B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surface],
  );
}
