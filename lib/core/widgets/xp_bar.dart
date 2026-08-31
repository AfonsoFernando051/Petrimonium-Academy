import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';

/// A thin, animated, glowing progress bar for XP/level progress — the same
/// visual language as `LearningHeroCard`'s private `_thinProgressBar`
/// (rounded gradient-glow fill over a track), promoted to a real shared
/// widget so other screens (onboarding's Gamification demo today) don't
/// have to re-hand-roll it. [progress] animates smoothly on change; honors
/// reduced-motion by jumping straight to the target value.
class XpBar extends StatelessWidget {
  const XpBar({
    super.key,
    required this.progress,
    this.label,
    this.color = AppColors.neonCyan,
    this.height = 8,
  });

  /// 0.0-1.0 fill fraction.
  final double progress;
  final String? label;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final clamped = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                color: tokens.textTertiary.withValues(alpha: 0.18),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clamped,
                child: AnimatedContainer(
                  duration: reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.75), color],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.55),
                        blurRadius: height,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label!,
            style: AppTextStyles.label.copyWith(color: tokens.textSecondary),
          ),
        ],
      ],
    );
  }
}
