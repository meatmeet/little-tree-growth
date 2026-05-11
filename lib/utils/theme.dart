import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryLighter = Color(0xFF74C69D);
  static const Color primaryPale = Color(0xFFD8F3DC);
  static const Color primaryBg = Color(0xFFF0FDF4);

  // Warm Accent
  static const Color warm = Color(0xFFF4A261);
  static const Color warmLight = Color(0xFFFDEBD0);
  static const Color warmBg = Color(0xFFFFF8EE);

  // Semantic
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFF4A261);
  static const Color danger = Color(0xFFE76F51);
  static const Color info = Color(0xFF48CAE4);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Background
  static const Color bgWarm = Color(0xFFFFFAF5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgMuted = Color(0xFFF8F9FA);

  // Shadows
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Noto Sans SC',
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: warm,
        surface: bgWarm,
        error: danger,
      ),
      scaffoldBackgroundColor: bgWarm,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // Area Colors
  static const Color areaGrossMotor = Color(0xFF15803D);
  static const Color areaFineMotor = Color(0xFF1D4ED8);
  static const Color areaLanguage = Color(0xFFB45309);
  static const Color areaAdaptation = Color(0xFF7C3AED);
  static const Color areaSocial = Color(0xFFBE185D);

  static Color getAreaColor(String area) {
    switch (area) {
      case 'gross_motor':
        return areaGrossMotor;
      case 'fine_motor':
        return areaFineMotor;
      case 'language':
        return areaLanguage;
      case 'adaptation':
        return areaAdaptation;
      case 'social':
        return areaSocial;
      default:
        return primary;
    }
  }

  static String getAreaIcon(String area) {
    switch (area) {
      case 'gross_motor':
        return '🏃';
      case 'fine_motor':
        return '✋';
      case 'language':
        return '🗣';
      case 'adaptation':
        return '🧩';
      case 'social':
        return '🤝';
      default:
        return '📊';
    }
  }

  static String getAreaName(String area) {
    switch (area) {
      case 'gross_motor':
        return '大运动';
      case 'fine_motor':
        return '精细动作';
      case 'language':
        return '语言';
      case 'adaptation':
        return '认知';
      case 'social':
        return '社交';
      default:
        return area;
    }
  }
}
