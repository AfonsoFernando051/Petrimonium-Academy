import 'package:flutter/material.dart';

/// Raw brand palette. Surfaces/text/backgrounds should NOT be read from here
/// directly anymore — use `context.colors` (`AppColorTokens`, see
/// `core/theme/app_color_tokens.dart`), which resolves to the right value
/// for the active Light/Dark/System theme.
///
/// The neon/gold accents below are the exception: pet auras, achievement
/// glow and other gamification highlights are meant to read as the exact
/// same brand color in both themes (only what surrounds them adapts), so
/// they stay theme-invariant constants here rather than tokens.
class AppColors {
  AppColors._();

  // Space theme backgrounds — dark theme only; use context.colors for
  // anything that must also work in Light.
  static const Color spaceDark   = Color(0xFF0A0A1A);
  static const Color spaceBlue   = Color(0xFF101835);
  static const Color spacePurple = Color(0xFF1A0B2E);

  // Legacy compatibility
  static const Color backgroundLight  = Color(0xFF6A11CB);
  static const Color backgroundMedium = Color(0xFF2C5364);
  static const Color backgroundDark   = Color(0xFF0F2027);

  static const Color primaryButton = Colors.deepPurple;

  static final Color white10 = Colors.white.withValues(alpha: 0.1);
  static final Color white20 = Colors.white.withValues(alpha: 0.2);
  static const Color white54 = Colors.white54;
  static const Color white70 = Colors.white70;
  static const Color white   = Colors.white;

  // Neon palette — primary brand colors
  static const Color neonCyan   = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFFC5ABFF); // brightened for AA contrast
  static const Color neonViolet = Color(0xFF8A2BE2); // replaces all inline 0xFF8A2BE2
  static const Color neonBlue   = Color(0xFF2979FF);
  static const Color neonPink   = Color(0xFFFF2A85);
  static const Color goldenBorder = Color(0xFFFFD54F);

  /// The product's single strongest visual signature — progression, XP,
  /// rewards, primary CTAs, "this is the current step" states. Reused as a
  /// constant (rather than redefined per widget) so every gradient moment
  /// in the app reads as the same brand gesture.
  static const List<Color> brandGradient = [neonViolet, neonPink];

  // Semantic / state colors — themed, NOT generic Material defaults
  static const Color positiveGreen = Color(0xFF00E676); // neon green
  static const Color negativeRed   = Color(0xFFFF1744); // vivid red
  static const Color warningAmber  = Color(0xFFFFAB40); // alert amber

  // Subdued text — better contrast than Colors.white70 on dark glass
  static const Color subtleText = Color(0xFFCBCDD8);
}
