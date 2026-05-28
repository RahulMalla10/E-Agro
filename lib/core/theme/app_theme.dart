import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Farmer-friendly UI with readable Nepali typography and accessible tabs.
class AppTheme {
  static const _seed = Color(0xFF2E7D32);
  static const _surfaceLight = Color(0xFFF5F7F2);
  static const _surfaceDark = Color(0xFF121814);

  static ThemeData light({String languageCode = 'en'}) =>
      _build(brightness: Brightness.light, languageCode: languageCode);

  static ThemeData dark({String languageCode = 'en'}) =>
      _build(brightness: Brightness.dark, languageCode: languageCode);

  static ThemeData _build({
    required Brightness brightness,
    required String languageCode,
  }) {
    final isDark = brightness == Brightness.dark;
    final isNepali = languageCode == 'ne';

    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      surface: isDark ? _surfaceDark : _surfaceLight,
    );

    final baseText = isNepali
        ? GoogleFonts.notoSansDevanagariTextTheme(
            ThemeData(brightness: brightness).textTheme,
          )
        : GoogleFonts.notoSansTextTheme(
            ThemeData(brightness: brightness).textTheme,
          );

    final tabLabelSize = isNepali ? 15.0 : 14.0;
    final navLabelSize = isNepali ? 13.0 : 12.0;

    final textTheme = baseText.copyWith(
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontSize: isNepali ? 28 : 26,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontSize: isNepali ? 22 : 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontSize: isNepali ? 19 : 17,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        fontSize: isNepali ? 19 : 18,
        height: 1.5,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        fontSize: isNepali ? 17 : 16,
        height: 1.5,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontSize: isNepali ? 16 : 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseText.labelMedium?.copyWith(fontSize: isNepali ? 15 : 13),
      labelSmall: baseText.labelSmall?.copyWith(fontSize: navLabelSize),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: textTheme.bodyMedium?.fontFamily,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.labelLarge?.copyWith(
          fontSize: tabLabelSize,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(
          fontSize: tabLabelSize,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 1,
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            fontSize: navLabelSize,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: colorScheme.surfaceContainer,
        elevation: 8,
      ),
      textTheme: textTheme,
    );
  }
}
