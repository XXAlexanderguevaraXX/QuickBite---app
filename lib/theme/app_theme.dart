import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class AppTheme {
  static const primary = Color(0xFFEA580C);
  static const primaryLight = Color(0xFFFFEDD5);
  static const bgMain = Color(0xFFF9FAFB);
  static const textMain = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  static final Map<AppThemeMode, ThemeData> themes = {
    AppThemeMode.light: light,
    AppThemeMode.softDark: softDark,
    AppThemeMode.midnight: midnight,
  };

  static ThemeData get light {
    return _baseTheme(
      brightness: Brightness.light,
      bg: bgMain,
      surface: Colors.white,
      text: textMain,
      secText: textSecondary,
      primary: primary,
      input: const Color(0xFFF3F4F6),
    );
  }

  static ThemeData get softDark {
    return _baseTheme(
      brightness: Brightness.dark,
      bg: const Color(0xFF111827),
      surface: const Color(0xFF1F2937),
      text: const Color(0xFFF3F4F6),
      secText: const Color(0xFF9CA3AF),
      primary: const Color(0xFFF97316),
      input: const Color.fromARGB(255, 81, 70, 55),
    );
  }

  static ThemeData get midnight {
    return _baseTheme(
      brightness: Brightness.dark,
      bg: const Color(0xFF000000),
      surface: const Color(0xFF0A0A0A),
      text: const Color(0xFFFFFFFF),
      secText: const Color(0xFFA1A1AA),
      primary: const Color(0xFFFB923C),
      input: const Color(0xFF171717),
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color secText,
    required Color primary,
    required Color input,
  }) {
    final baseColorScheme = brightness == Brightness.light
        ? const ColorScheme.light()
        : const ColorScheme.dark();

    final colorScheme = baseColorScheme.copyWith(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: primary.withOpacity(0.8),
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      outline: input,
    );

    final baseTextTheme =
        GoogleFonts.interTextTheme(ThemeData(brightness: brightness).textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: baseTextTheme
          .copyWith(
            displayLarge: baseTextTheme.displayLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: text),
            displayMedium: baseTextTheme.displayMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: text),
            headlineSmall: baseTextTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            titleLarge:
                baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: text),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: secText),
            labelLarge: baseTextTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          )
          .apply(bodyColor: text, displayColor: text),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(color: text),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      iconTheme: IconThemeData(color: text),
      
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        hintStyle: TextStyle(color: secText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerColor: input,
    );
  }
}
