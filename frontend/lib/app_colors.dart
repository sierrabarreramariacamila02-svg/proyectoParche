import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color backgroundLight = Color(0xFFF7F3E7);
  static const Color background = backgroundLight;
  static const Color primaryOrange = Color(0xFFD35400);
  static const Color orangeButton = Color(0xFFE5A059);
  static const Color buttonOrange = orangeButton;
  static const Color inputBackground = Color(0xFFF2EAD8);
  static const Color barraHome = Color(0xFF8C0E0E);
  static const Color barraInferior = Color(0xFFF1D5BC);
  static const Color darkRed = barraHome;
  static const Color black = Colors.black87;
  static const Color white = Colors.white;

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkRed,
        primary: darkRed,
        secondary: orangeButton,
        surface: backgroundLight,
      ),
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkRed,
        foregroundColor: white,
        elevation: 0,
      ),
    );
  }
}

class AppColors {
  AppColors._();

  static const Color background = AppTheme.background;
  static const Color primaryOrange = AppTheme.primaryOrange;
  static const Color buttonOrange = AppTheme.buttonOrange;
  static const Color inputBackground = AppTheme.inputBackground;
  static const Color barraHome = AppTheme.barraHome;
  static const Color barraInferior = AppTheme.barraInferior;
}
