import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// The app's two `ThemeData` instances. `MaterialApp` is given both
/// (`theme`/`darkTheme`) plus a `themeMode`, so Flutter — not app code —
/// decides which one is active; every screen then reads colors through
/// `context.colors` (the [AppColorTokens] extension registered below)
/// instead of branching on brightness itself.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light, AppColorTokens.light);
  static ThemeData get dark => _build(Brightness.dark, AppColorTokens.dark);

  static ThemeData _build(Brightness brightness, AppColorTokens tokens) {
    final base = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
    final textTheme = GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: tokens.textPrimary,
      displayColor: tokens.textPrimary,
    );

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: tokens.backgroundPrimary,
      textTheme: textTheme,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: tokens.primary,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        secondary: tokens.secondary,
        onSecondary: Colors.white,
        error: tokens.error,
        onError: Colors.white,
        surface: tokens.surface,
        onSurface: tokens.textPrimary,
      ),
      dividerColor: tokens.divider,
      iconTheme: IconThemeData(color: tokens.textSecondary),
      splashColor: tokens.primary.withValues(alpha: 0.12),
      highlightColor: tokens.primary.withValues(alpha: 0.06),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: tokens.surfaceElevated,
        contentTextStyle: GoogleFonts.outfit(color: tokens.textPrimary, fontWeight: FontWeight.w600),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.backgroundSecondary,
        selectedItemColor: tokens.primary,
        unselectedItemColor: tokens.textTertiary,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      extensions: [tokens],
    );
  }
}
