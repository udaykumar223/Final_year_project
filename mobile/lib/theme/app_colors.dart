import 'package:flutter/material.dart';

/// SmartCrop AI — Ultra-Premium Nature + AI Design System Colors
class AppColors {
  // Brand Primary & Accents (Deep Forest Emerald & Neon Mint)
  static const Color primary = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF047857);
  static const Color secondary = Color(0xFF34D399);
  static const Color accent = Color(0xFF34D399);
  static const Color accentGlow = Color(0xFF6EE7B7);

  // Background & Surfaces (Rich Glassmorphic Nature Theme)
  static const Color background = Color(0xFF0A1612);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFF11221C);
  static const Color surfaceGlass = Color(0xCC11221C);
  static const Color surfaceCard = Color(0xFF162D25);
  static const Color surfaceVariant = Color(0xFF1C382E);

  // Card Borders & Glows
  static const Color border = Color(0xFF23473B);
  static const Color borderGlow = Color(0xFF10B981);
  static const Color divider = Color(0xFF1E3D32);
  static const Color shadow = Color(0xFF000000);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Crop Accents
  static const Color bananaAccent = Color(0xFFF59E0B);
  static const Color groundnutAccent = Color(0xFFD97706);
  static const Color radishAccent = Color(0xFF10B981);

  // Status & Severity Colors
  static const Color healthy = Color(0xFF10B981);
  static const Color mild = Color(0xFFF59E0B);
  static const Color moderate = Color(0xFFF97316);
  static const Color severe = Color(0xFFEF4444);

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0x2610B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0x26F59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0x26EF4444);
  static const Color info = Color(0xFF38BDF8);
  static const Color infoLight = Color(0x2638BDF8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF047857), Color(0xFF064E3B), Color(0xFF022C22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF162D25), Color(0xFF0E1F19)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x3310B981), Color(0x0D10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scannerLaserGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xFF34D399), Colors.transparent],
    stops: [0.0, 0.5, 1.0],
  );
}
