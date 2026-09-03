import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';

/// The neon-cyan-outlined "field" look shared by every input on
/// `InvestmentConfigurationScreen` — plain `TextFormField`s (`_buildTextField`),
/// the ticker `Autocomplete` field, and the date-picker's tappable
/// `Container` all rendered their own copy of this before, three ways to
/// drift out of sync. [investmentFieldFill]/[investmentFieldBorder] cover the
/// `Container`-based date field; [investmentInputDecoration] wraps them for
/// the two real `TextFormField`s.
Color investmentFieldFill(BuildContext context) {
  final tokens = context.colors;
  return tokens.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94);
}

Border investmentFieldBorder({double alpha = 0.4}) {
  return Border.all(color: AppColors.neonCyan.withValues(alpha: alpha));
}

OutlineInputBorder _outline({required double alpha, double width = 1.0}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
    borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: alpha), width: width),
  );
}

InputDecoration investmentInputDecoration(
  BuildContext context, {
  required String label,
  Widget? suffixIcon,
}) {
  final tokens = context.colors;
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: tokens.textSecondary),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: investmentFieldFill(context),
    border: _outline(alpha: 0.5),
    enabledBorder: _outline(alpha: 0.4),
    focusedBorder: _outline(alpha: 1.0, width: 1.5),
  );
}
