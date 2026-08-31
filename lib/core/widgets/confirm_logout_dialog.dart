import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/utils/translator.dart';

/// The app's single logout-confirmation dialog, shown from both Dashboard
/// and Settings. Centralizing it means there's exactly one place that needs
/// to stay in sync with `Translator`/`AppStrings` — previously each screen
/// implemented its own copy, and only one of them was actually localized.
class ConfirmLogoutDialog {
  ConfirmLogoutDialog._();

  /// Shows the dialog and resolves to `true` if the user confirmed logout.
  static Future<bool> show(BuildContext context) async {
    final tokens = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
        title: Text(
          Translator.translate(AppStrings.logoutConfirmTitle),
          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          Translator.translate(AppStrings.logoutConfirmMessage),
          style: TextStyle(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(Translator.translate(AppStrings.cancelButton), style: TextStyle(color: tokens.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(Translator.translate(AppStrings.logoutButton), style: TextStyle(color: tokens.error)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}
