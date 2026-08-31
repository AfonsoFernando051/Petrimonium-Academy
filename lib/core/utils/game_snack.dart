import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// Utility for themed, branded snack bars.
/// Replaces all raw ScaffoldMessenger.showSnackBar calls.
class GameSnack {
  GameSnack._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    final tokens = context.colors;
    final color = isError
        ? tokens.error.withValues(alpha: 0.92)
        : isSuccess
            ? tokens.success.withValues(alpha: 0.92)
            : tokens.surfaceElevated.withValues(alpha: 0.98);

    final icon = isError
        ? Icons.error_outline
        : isSuccess
            ? Icons.check_circle_outline
            : Icons.info_outline;

    // Neutral (non-success/error) snacks sit on a plain surface — that
    // surface is near-white in Light theme, so its content needs dark text,
    // unlike the always-white text used over the saturated success/error fills.
    final isNeutralLight = !isError && !isSuccess && !context.isDarkMode;
    final contentColor = isNeutralLight ? tokens.textPrimary : Colors.white;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: contentColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isError
                ? tokens.error
                : isSuccess
                    ? tokens.success
                    : tokens.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Convenience: light haptic + show
  static void showWithHaptic(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    HapticFeedback.lightImpact();
    show(context, message, isError: isError, isSuccess: isSuccess);
  }
}
