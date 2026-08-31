import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// A generic animated gradient progress bar — same visual language as
/// `PortfolioProgressBar`, kept separate since that widget's label copy is
/// specific to portfolio onboarding, not reusable as-is for lesson/module
/// progress.
class AcademyProgressBar extends StatelessWidget {
  const AcademyProgressBar({super.key, required this.progress, this.height = 8, this.color});

  final double progress;
  final double height;

  /// Overrides the default violet→cyan gradient with a single flat color —
  /// used by Mastery bars to reflect the current `MasteryTier`'s color.
  /// `null` (the default) keeps the original gradient everywhere else.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final clamped = progress.clamp(0.0, 1.0);
    final barColor = color;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: tokens.textPrimary.withValues(alpha: 0.08)),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: barColor,
                  gradient: barColor == null
                      ? const LinearGradient(colors: [AppColors.neonViolet, AppColors.neonCyan])
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
