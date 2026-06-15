import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFF0A0B14);
  static const Color surface = Color(0xFF12131E);
  static const Color card = Color(0xFF1C1D2E);
  static const Color cardElevated = Color(0xFF22233A);
  static const Color border = Color(0xFF2A2B3D);
  static const Color borderLight = Color(0xFF3A3B52);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9B9BBF);
  static const Color textMuted = Color(0xFF5A5B78);
  static const Color textDisabled = Color(0xFF3A3B52);

  // Brand
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF8B5CF6);

  // Realm Colors
  static const Color logicRealm = Color(0xFF6366F1);
  static const Color strategyRealm = Color(0xFF8B5CF6);
  static const Color memoryRealm = Color(0xFF14B8A6);
  static const Color mathRealm = Color(0xFFF59E0B);
  static const Color creativityRealm = Color(0xFFEC4899);
  static const Color innovationRealm = Color(0xFF10B981);
  static const Color mastermindRealm = Color(0xFFEF4444);

  // TCI Rating Colors
  static const Color tciGrandmaster = Color(0xFFFFD700);
  static const Color tciMaster = Color(0xFFE879F9);
  static const Color tciExpert = Color(0xFF22D3EE);
  static const Color tciAdvanced = Color(0xFF4ADE80);
  static const Color tciIntermediate = Color(0xFF60A5FA);
  static const Color tciBeginner = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF6366F1);

  // Streak
  static const Color streakFire = Color(0xFFFF6B35);
  static const Color streakGold = Color(0xFFFFD700);

  // XP
  static const Color xpGold = Color(0xFFFFD700);
  static const Color xpBlue = Color(0xFF6366F1);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0B14), Color(0xFF0F1020)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient logicGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient strategyGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient memoryGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mathGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient creativityGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient innovationGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mastermindGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme colors
  static const Color lightBackground = Color(0xFFF8F9FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F2FF);
  static const Color lightBorder = Color(0xFFE4E5F0);
  static const Color lightTextPrimary = Color(0xFF0A0B14);
  static const Color lightTextSecondary = Color(0xFF4B4C6B);
  static const Color lightTextMuted = Color(0xFF9B9BBF);
}
