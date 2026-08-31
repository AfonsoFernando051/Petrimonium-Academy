import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Where/how prominently an [ErrorStateView] renders — previously each
/// screen (`AssetDetailsScreen`, `PortfolioScreen`,
/// `DividendNotificationsSheet`) hand-rolled its own near-identical
/// icon+message+retry block with its own "Tentar novamente" button.
enum ErrorStateStyle {
  /// Full-bleed section error, no card chrome (e.g. Asset Details body).
  standard,

  /// Same content wrapped in a [GlassCard] for a screen whose other states
  /// (loading/content) already sit inside cards (e.g. Portfolio).
  card,

  /// Small inline error inside an already-scoped container (e.g. a bottom
  /// sheet section) — smaller icon, a text-only retry action instead of a
  /// filled button.
  compact,
}

/// Shared "something failed, here's why, try again" state. See
/// [ErrorStateStyle] for the three visual treatments in use across the app.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title,
    this.style = ErrorStateStyle.standard,
  });

  /// Optional bold headline shown above [message]. `compact` style never
  /// shows a title (there isn't room for one in an inline section error).
  final String? title;
  final String message;
  final Future<void> Function() onRetry;
  final ErrorStateStyle style;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    if (style == ErrorStateStyle.compact) {
      return Column(
        children: [
          Icon(Icons.satellite_alt, color: tokens.error, size: 32),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: tokens.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: AppColors.neonCyan, size: 16),
            label: Text(
              Translator.translate(AppStrings.retryButtonLabel),
              style: const TextStyle(color: AppColors.neonCyan),
            ),
          ),
        ],
      );
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.satellite_alt, size: 56, color: tokens.error),
        const SizedBox(height: AppSpacing.lg),
        if (title != null) ...[
          Text(
            title!,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(color: tokens.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(Translator.translate(AppStrings.retryButtonLabel)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonViolet, foregroundColor: Colors.white),
        ),
      ],
    );

    if (style == ErrorStateStyle.card) {
      return Center(
        child: GlassCard(
          backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
          borderColor: tokens.error.withValues(alpha: 0.4),
          borderRadius: AppRadii.xxl,
          child: Padding(padding: const EdgeInsets.all(28), child: content),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: content,
      ),
    );
  }
}
