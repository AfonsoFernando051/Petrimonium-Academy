import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/utils/translator.dart';

/// "Reiniciar a simulação mediante confirmação" — mirrors
/// `ConfirmLogoutDialog`'s shape (the app's one other destructive-action
/// dialog) so both read as visually consistent.
class ResetSimulatedWalletDialog {
  ResetSimulatedWalletDialog._();

  /// Shows the dialog and resolves to `true` if the user confirmed the reset.
  static Future<bool> show(BuildContext context) async {
    final tokens = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
        title: Text(
          Translator.translate(AppStrings.simulatedWalletResetConfirmTitle),
          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          Translator.translate(AppStrings.simulatedWalletResetConfirmMessage),
          style: TextStyle(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(Translator.translate(AppStrings.cancelButton), style: TextStyle(color: tokens.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              Translator.translate(AppStrings.simulatedWalletResetConfirmAction),
              style: TextStyle(color: tokens.error),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}
