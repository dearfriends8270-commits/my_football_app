import 'package:flutter/material.dart';

/// K-SPORTS STAR 앱 컬러 팔레트
class AppColors {
  // Primary Dark Theme Colors
  static const Color background = Color(0xFF0A1628);
  static const Color backgroundLight = Color(0xFF0F1E36);
  static const Color backgroundCard = Color(0xFF162544);
  static const Color backgroundCardLight = Color(0xFF1E3A5F);

  // Accent Colors
  static const Color primary = Color(0xFF3B82F6); // Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color accent = Color(0xFFFFD700); // Gold
  static const Color accentOrange = Color(0xFFFF9500);

  // Status Colors
  static const Color live = Color(0xFFEF4444); // Red for live
  static const Color success = Color(0xFF22C55E); // Green
  static const Color warning = Color(0xFFF59E0B); // Yellow/Orange

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8C9);
  static const Color textMuted = Color(0xFF6B7280);

  // Border & Divider
  static const Color border = Color(0xFF2A3F5F);
  static const Color divider = Color(0xFF1E3A5F);

  // Sport Tab Colors
  static const Color footballTab = Color(0xFF22C55E);
  static const Color baseballTab = Color(0xFFEAB308);
  static const Color basketballTab = Color(0xFFEF4444);
  static const Color volleyballTab = Color(0xFF8B5CF6);

  // Gradient
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  );

  static LinearGradient cardGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF162544), Color(0xFF0F1E36)],
  );

  static LinearGradient goldGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFF9500)],
  );
}
