import 'package:flutter/material.dart';

/// Design system do Territory Insights: identidade editorial, contraste e componentes consistentes.
abstract final class AppTheme {
  static const Color _brand = Color(0xFF087F75);
  static const Color _navy = Color(0xFF102A43);
  static const Color _canvas = Color(0xFFF4F7F8);

  static ThemeData light({bool highContrast = false}) => _build(Brightness.light, highContrast);
  static ThemeData dark({bool highContrast = false}) => _build(Brightness.dark, highContrast);

  static ThemeData _build(Brightness brightness, bool highContrast) {
    final isDark = brightness == Brightness.dark;
    var scheme = ColorScheme.fromSeed(
      seedColor: _brand,
      brightness: brightness,
      primary: _brand,
      secondary: const Color(0xFF3D8DAD),
      surface: isDark ? const Color(0xFF14212B) : Colors.white,
    );
    if (highContrast) {
      scheme = isDark
          ? scheme.copyWith(primary: Colors.yellow, onPrimary: Colors.black, surface: Colors.black, onSurface: Colors.white, outline: Colors.white)
          : scheme.copyWith(primary: Colors.black, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black, outline: Colors.black);
    }
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0D171F) : _canvas,
      visualDensity: VisualDensity.standard,
    );
    final t = base.textTheme;
    return base.copyWith(
      textTheme: t.copyWith(
        headlineLarge: t.headlineLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.1, color: isDark ? Colors.white : _navy),
        headlineMedium: t.headlineMedium?.copyWith(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.7),
        headlineSmall: t.headlineSmall?.copyWith(fontSize: 23, fontWeight: FontWeight.w700, letterSpacing: -.4),
        titleLarge: t.titleLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -.25),
        titleMedium: t.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        bodyLarge: t.bodyLarge?.copyWith(fontSize: 14, height: 1.5),
        bodyMedium: t.bodyMedium?.copyWith(fontSize: 13, height: 1.45),
        bodySmall: t.bodySmall?.copyWith(fontSize: 12, height: 1.4, color: isDark ? Colors.white70 : const Color(0xFF647786)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0D171F) : _canvas,
        foregroundColor: isDark ? Colors.white : _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : _navy, letterSpacing: -.3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1B2A35) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _brand, width: 1.8)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(48, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w700))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), side: BorderSide(color: scheme.outlineVariant))),
      chipTheme: base.chipTheme.copyWith(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), side: BorderSide(color: scheme.outlineVariant)),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF14212B) : Colors.white,
        indicatorColor: scheme.primary.withAlpha(isDark ? 60 : 30),
        labelTextStyle: WidgetStatePropertyAll(const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withAlpha(150), thickness: 1),
    );
  }
}
