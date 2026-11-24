import 'package:flutter/material.dart';

class AppTheme {
  static const Color f1Red = Color(0xFFE10600);
  static const Color f1RedDark = Color(0xFFB30500);
  static const Color darkBg = Color(0xFF10111A);
  static const Color cardBg = Color(0xFF1A1B26);
  static const Color surfaceBg = Color(0xFF242536);
  static const Color cardBorder = Color(0xFF2F3247);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9E9EB4);
  static const Color textDark = Color(0xFF15151E);
  static const Color success = Color(0xFF00D26A);
  static const Color gold = Color(0xFFFFB800);
  static const Color soldOut = Color(0xFF88889A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: f1Red,
      colorScheme: const ColorScheme.dark(
        primary: f1Red,
        secondary: gold,
        surface: cardBg,
        onPrimary: textWhite,
        onSurface: textWhite,
        error: f1Red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textWhite),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: f1Red,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: f1Red,
          foregroundColor: textWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: f1Red, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: f1Red,
        unselectedLabelColor: textMuted,
        indicatorColor: f1Red,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}
