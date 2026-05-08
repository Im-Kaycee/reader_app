import 'package:flutter/material.dart';

class AppColors {
  // Light mode
  static const cream    = Color(0xFFF5F0E8);
  static const ink      = Color(0xFF1A1A1A);
  static const white    = Color(0xFFFFFFFF);
  static const paper    = Color(0xFFEDE8DE);

  // Dark mode
  static const darkBg      = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkPaper   = Color(0xFF242424);
  static const darkInk     = Color(0xFFF5F0E8);

  // Category accents — same in both modes
  static const tech     = Color(0xFF00C896);
  static const security = Color(0xFFFF3B30);
  static const music    = Color(0xFF8B5CF6);
  static const culture  = Color(0xFFFFB800);
  static const football = Color(0xFF1A8F3C);
  static const nigeria  = Color(0xFF008751);
  static const general  = Color(0xFF555555);

  static Color forCategory(String category) {
    switch (category) {
      case 'tech':     return tech;
      case 'security': return security;
      case 'music':    return music;
      case 'culture':  return culture;
      case 'football': return football;
      case 'nigeria':  return nigeria;
      case 'general':  return general;
      default:         return ink;
    }
  }

  static Color labelColorFor(Color background) {
    return background.computeLuminance() > 0.4 ? ink : white;
  }
}

class AppTextStyles {
  static const headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const cardTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const muted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF888888),
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.light(
      primary: AppColors.ink,
      surface: AppColors.cream,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: AppColors.ink,
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkInk,
      surface: AppColors.darkBg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkInk,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: AppColors.darkInk,
  );

  // Keep this for backward compat
  static ThemeData get theme => light;
}