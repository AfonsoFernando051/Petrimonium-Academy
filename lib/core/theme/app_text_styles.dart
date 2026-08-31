import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic type scale, derived from the font sizes already in ad hoc use
/// across the app (11/12/13/14/16/18/20/28) and built on the same Outfit
/// family `AppTheme` wires into the global `TextTheme`.
///
/// Deliberately colorless — every getter omits `color`, matching how
/// [AppColorTokens] is consumed: callers apply intent via
/// `AppTextStyles.body.copyWith(color: context.colors.textPrimary)` rather
/// than this class making a light/dark decision it has no context for.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get caption => GoogleFonts.outfit(fontSize: 11);
  static TextStyle get label => GoogleFonts.outfit(fontSize: 12);
  static TextStyle get body => GoogleFonts.outfit(fontSize: 13);
  static TextStyle get bodyEmphasis => GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get title => GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold);
  static TextStyle get titleLarge => GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold);
  static TextStyle get headline => GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold);
  static TextStyle get display => GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold);
}
