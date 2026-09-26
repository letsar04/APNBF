import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();
  static const primary = Color(0xFFE87511);
  static const ink = Color(0xFF1D2329);
  static const background = Color(0xFFF6F7F8);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(primary: primary, onPrimary: Colors.white, surface: Colors.white),
      scaffoldBackgroundColor: background,
      fontFamily: 'sans',
      appBarTheme: const AppBarTheme(backgroundColor: background, foregroundColor: ink, elevation: 0, centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide.none),
        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: primary.withOpacity(.55), width: 1.5)),
      ),
      cardTheme: const CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, surfaceTintColor: Colors.transparent),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w700))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      chipTheme: ChipThemeData(backgroundColor: primary.withOpacity(.10), labelStyle: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
