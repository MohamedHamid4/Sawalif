import 'package:flutter/material.dart';

/// ألوان تطبيق سوالف - تدرّج برتقالي/أحمر دافئ 🔥
/// نظام ألوان دافئ برتقالي/أحمر حيوي
class AppColors {
  AppColors._();

  // ===== الألوان الأساسية =====
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A5B);
  static const Color primaryDark = Color(0xFFE55A2B);

  static const Color secondary = Color(0xFFE63946);
  static const Color secondaryLight = Color(0xFFF25F6B);
  static const Color secondaryDark = Color(0xFFC92E3C);

  static const Color accent = Color(0xFFFFB627);

  // ===== حالات النظام =====
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFB627);
  static const Color error = Color(0xFFE63946);
  static const Color online = Color(0xFF06D6A0);

  // ===== الـ Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, primary, secondary],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF8A5B), Color(0xFFFF6B35), Color(0xFFE63946)],
  );

  // ===== Light Mode =====
  static const Color lightBg = Color(0xFFFFF8F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2B2118);
  static const Color lightTextSecondary = Color(0xFF8B7E74);
  static const Color lightDivider = Color(0xFFFFE5D6);
  static const Color lightInputBg = Color(0xFFFFF3EA);

  // ===== Dark Mode =====
  static const Color darkBg = Color(0xFF1A0F0A);
  static const Color darkSurface = Color(0xFF2B1B14);
  static const Color darkCard = Color(0xFF3D2A20);
  static const Color darkTextPrimary = Color(0xFFFFF8F3);
  static const Color darkTextSecondary = Color(0xFFB89F8F);
  static const Color darkDivider = Color(0xFF4A3527);
  static const Color darkInputBg = Color(0xFF2B1B14);

  // ===== فقاعات الرسائل =====
  static const Color otherMessageLightBg = Color(0xFFFFFFFF);
  static const Color otherMessageDarkBg = Color(0xFF3D2A20);

  // ===== ظلال برتقالية خفيفة =====
  static Color shadowColor = primary.withValues(alpha: 0.15);
  static Color cardShadow = primary.withValues(alpha: 0.08);
}
