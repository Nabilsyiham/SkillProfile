import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorTheme {
  final String name;
  final String label;
  final Color primary;
  final Color canvas;
  final Color surface;

  const ColorTheme({
    required this.name,
    required this.label,
    required this.primary,
    required this.canvas,
    required this.surface,
  });
}

const List<ColorTheme> colorThemes = [
  ColorTheme(
    name: 'default',
    label: 'Classic',
    primary: Color(0xFF1E1E1C),
    canvas: Color(0xFFFAF9F5),
    surface: Color(0xFFF3F2EC),
  ),
  ColorTheme(
    name: 'ocean',
    label: 'Ocean',
    primary: Color(0xFF2C5F7C),
    canvas: Color(0xFFF0F5F8),
    surface: Color(0xFFE1EBF0),
  ),
  ColorTheme(
    name: 'sage',
    label: 'Sage',
    primary: Color(0xFF5C7A5E),
    canvas: Color(0xFFF2F5F0),
    surface: Color(0xFFE5EBE3),
  ),
  ColorTheme(
    name: 'rose',
    label: 'Rose',
    primary: Color(0xFF8B5E6B),
    canvas: Color(0xFFF8F0F2),
    surface: Color(0xFFF0E0E4),
  ),
  ColorTheme(
    name: 'sand',
    label: 'Sand',
    primary: Color(0xFF7A6B5D),
    canvas: Color(0xFFF5F2ED),
    surface: Color(0xFFEBE5DC),
  ),
  ColorTheme(
    name: 'lavender',
    label: 'Lavender',
    primary: Color(0xFF6B5E8B),
    canvas: Color(0xFFF3F0F8),
    surface: Color(0xFFE6E0F0),
  ),
  ColorTheme(
    name: 'slate',
    label: 'Slate',
    primary: Color(0xFF5A6872),
    canvas: Color(0xFFF1F3F5),
    surface: Color(0xFFE2E6EA),
  ),
  ColorTheme(
    name: 'terracotta',
    label: 'Terracotta',
    primary: Color(0xFF8B6B5A),
    canvas: Color(0xFFF5F0ED),
    surface: Color(0xFFEBE0DA),
  ),
];

class ThemeNotifier extends StateNotifier<ColorTheme> {
  ThemeNotifier() : super(colorThemes[0]) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('color_theme') ?? 'default';
    state = colorThemes.firstWhere((t) => t.name == name, orElse: () => colorThemes[0]);
  }

  Future<void> setTheme(ColorTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('color_theme', theme.name);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ColorTheme>((ref) {
  return ThemeNotifier();
});

ThemeData buildTheme(ColorTheme colorTheme) {
  final pebble = HSLColor.fromColor(colorTheme.primary).withLightness(0.55).toColor();

  return ThemeData(
    brightness: Brightness.light,
    primaryColor: colorTheme.primary,
    scaffoldBackgroundColor: colorTheme.canvas,
    colorScheme: ColorScheme.light(
      primary: colorTheme.primary,
      secondary: pebble,
      surface: colorTheme.surface,
      error: Colors.redAccent,
    ),
    textTheme: GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.manrope(
        color: colorTheme.primary,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.manrope(
        color: colorTheme.primary,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.manrope(
        color: colorTheme.primary,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.manrope(
        color: colorTheme.primary,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.manrope(
        color: colorTheme.primary,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      labelLarge: GoogleFonts.manrope(
        color: colorTheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorTheme.canvas,
      foregroundColor: colorTheme.primary,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorTheme.surface,
      selectedItemColor: colorTheme.primary,
      unselectedItemColor: pebble,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorTheme.primary,
        foregroundColor: colorTheme.canvas,
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
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorTheme.primary,
        side: BorderSide(color: colorTheme.primary),
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
