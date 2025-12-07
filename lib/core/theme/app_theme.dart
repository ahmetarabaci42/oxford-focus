import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final TextTheme _googleTextTheme = GoogleFonts.poppinsTextTheme();

  static const Color _neonCyan = Color(0xFF00E5FF);
  static const Color _neonPink = Color(0xFFFF4081);
  static const Color _background = Color(0xFF121212);
  static const Color _surface = Color(0xFF1E1E1E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _neonCyan,
        secondary: _neonPink,
        surface: _surface,
        background: _background,
      ),
      scaffoldBackgroundColor: _background,
      textTheme: _googleTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _neonCyan,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
