import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();
  static const primary = Color(0xFFE87511);
  static const background = Color(0xFFF7F7F5);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(primary: primary, onPrimary: Colors.white, surface: Colors.white),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(backgroundColor: background, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide.none),
      ),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero),
    );
  }
}
