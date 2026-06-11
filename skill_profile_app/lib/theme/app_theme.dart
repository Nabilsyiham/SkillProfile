import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from DESIGN.md and index.html
  static const Color canvas = Color(0xFFFAF9F5);
  static const Color surface = Color(0xFFF3F2EC);
  static const Color surfaceHigh = Color(0xFFEBEAE3);
  static const Color charcoal = Color(0xFF1E1E1C);
  static const Color pebble = Color(0xFF7B7973);
  static const Color linen = Color(0xFFE4E2D9);
  static const Color sage = Color(0xFF8D9387);
  static const Color clay = Color(0xFFC8C2B8);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: charcoal,
      scaffoldBackgroundColor: canvas,
      colorScheme: const ColorScheme.light(
        primary: charcoal,
        secondary: pebble,
        surface: surface,

        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(
          color: charcoal,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.manrope(
          color: charcoal,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.manrope(
          color: charcoal,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        bodyLarge: GoogleFonts.manrope(
          color: charcoal,
          fontWeight: FontWeight.w400,
          height: 1.6, // leading-relaxed
        ),
        bodyMedium: GoogleFonts.manrope(
          color: charcoal,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        labelLarge: GoogleFonts.manrope(
          color: charcoal,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5, // uppercase tracking
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: charcoal,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: charcoal,
        unselectedItemColor: pebble,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoal,
          foregroundColor: canvas,
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // rounded = 0.25rem = 4px
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoal,
          side: const BorderSide(color: charcoal),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: charcoal,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: charcoal,
        secondary: pebble,
        surface: Color(0xFF1E1E1C),
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        bodyLarge: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        labelLarge: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1C),
        selectedItemColor: Colors.white,
        unselectedItemColor: pebble,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
