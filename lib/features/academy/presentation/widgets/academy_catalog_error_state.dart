import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Shown instead of a screen's curriculum content when the Academy catalog
/// could neither be fetched nor loaded from cache (see
/// `AcademyController.catalogError`) — e.g. the very first launch with no
/// connectivity. Distinct from the shared `ErrorBanner`: that one overlays
/// stale-but-usable cached content, this one replaces content that was
/// never available to begin with.
class AcademyCatalogErrorState extends StatelessWidget {
  const AcademyCatalogErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          borderColor: tokens.error.withValues(alpha: 0.4),
          borderRadius: 20,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, color: tokens.error, size: 32),
                const SizedBox(height: 12),
                Text(
                  Translator.translate(AppStrings.academyCatalogErrorTitle),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Translator.translate(AppStrings.academyCatalogErrorBody),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                GameButton(
                  label: Translator.translate(AppStrings.retryButtonLabel),
                  icon: Icons.refresh_rounded,
                  colors: const [AppColors.neonBlue, AppColors.neonCyan],
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
