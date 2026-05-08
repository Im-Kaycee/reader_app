import 'package:flutter/material.dart';

class AppColors {
  static const cream    = Color(0xFFF5F0E8);
  static const ink      = Color(0xFF1A1A1A);
  static const white    = Color(0xFFFFFFFF);
  static const paper    = Color(0xFFEDE8DE);

  static const tech     = Color(0xFF00C896);
  static const security = Color(0xFFFF3B30);
  static const music    = Color(0xFF8B5CF6);
  static const culture  = Color(0xFFFFB800);
  static const football = Color.fromARGB(255, 12, 32, 18);
  static const general  = Color(0xFF555555); // dark gray — visible text
static const nigeria = Color(0xFF008751); // Nigerian green
  static Color forCategory(String category) {
    switch (category) {
      case 'tech':     return tech;
      case 'security': return security;
      case 'music':    return music;
      case 'culture':  return culture;
      case 'football': return football;
      case 'general':  return general;
      case 'nigeria':  return nigeria;
      default:         return ink;
    }
  }

  // Returns black or white depending on which is more readable on the bg
  static Color labelColorFor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.4 ? ink : white;
  }
}

class AppTextStyles {
  static const headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: AppColors.ink,
    height: 1.1,
  );

  static const cardTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.ink,
    height: 1.25,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.6,
  );

  static const muted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF888888),
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
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
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        color: AppColors.ink,
      ),
    ),
    dividerColor: AppColors.ink,
  );
}