import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Pastel palette
  static const mint        = Color(0xFFD4F1E4);
  static const mintMid     = Color(0xFFA8E2C8);
  static const mintDark    = Color(0xFF3AAD7A);
  static const mintDeep    = Color(0xFF1E7A54);
  static const peach       = Color(0xFFFDE8D8);
  static const peachMid    = Color(0xFFF9C8A8);
  static const peachDark   = Color(0xFFE07A45);
  static const lavender    = Color(0xFFEDE8F8);
  static const lavenderMid = Color(0xFFC9BCEE);
  static const lavenderDark= Color(0xFF7B5FC4);
  static const cream       = Color(0xFFFDF8F0);
  static const warmWhite   = Color(0xFFFFF9F4);
  static const textDark    = Color(0xFF2C2235);
  static const textMid     = Color(0xFF5A4F6A);
  static const textLight   = Color(0xFF9A8FAA);
  static const cardBg      = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.mintDark,
      background: AppColors.cream,
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 34, color: AppColors.textDark),
      displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 28, color: AppColors.textDark),
      displaySmall: GoogleFonts.dmSerifDisplay(
          fontSize: 22, color: AppColors.textDark),
      headlineMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 18, color: AppColors.textDark),
      bodyLarge: GoogleFonts.nunito(
          fontSize: 15, color: AppColors.textDark),
      bodyMedium: GoogleFonts.nunito(
          fontSize: 13, color: AppColors.textMid),
      bodySmall: GoogleFonts.nunito(
          fontSize: 11, color: AppColors.textLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mintDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.nunito(
            fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.mintMid, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.mintMid, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.mintDark, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

// Gradient helpers
LinearGradient get primaryGradient => const LinearGradient(
  colors: [AppColors.mintDark, AppColors.lavenderDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

LinearGradient get splashGradient => const LinearGradient(
  colors: [Color(0xFFE8F8EF), Color(0xFFF8EDF8), Color(0xFFFDE8D8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
