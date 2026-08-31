import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';

/// How prominently an [EmptyStateView] renders — mirrors [ErrorStateStyle]'s
/// reasoning: a screen's empty state should read at the same visual weight
/// as its loading/error states, not swing from a bare line of text in one
/// feature to a fully illustrated moment in another.
enum EmptyStateStyle {
  /// Full-bleed section empty state (e.g. an empty holdings list).
  standard,

  /// Smaller icon, tighter spacing, for an empty state inside an
  /// already-scoped container (e.g. a section nested in a bigger screen).
  compact,
}

/// Shared "nothing here yet, here's why, here's what to do" state —
/// previously each feature (Holdings, Achievements, Missions) hand-rolled
/// its own empty-state copy at a different level of polish. Mirrors
/// [ErrorStateView]'s shape so a screen's loading/empty/error states read as
/// one consistent system rather than three unrelated ones.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.style = EmptyStateStyle.standard,
  });

  final IconData icon;

  /// Optional bold headline shown above [message]. Omit for a `compact`
  /// empty state — there usually isn't room for one.
  final String? title;

  /// Explains both why it's empty and, where possible, what the user can do
  /// next — never just "Nothing here."
  final String message;

  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateStyle style;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final compact = style == EmptyStateStyle.compact;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 32 : 48, color: tokens.textTertiary),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: (compact ? AppTextStyles.bodyEmphasis : AppTextStyles.title).copyWith(color: tokens.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs + 2),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
