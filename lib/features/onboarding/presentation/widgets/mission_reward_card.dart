import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// "🎯 Mission Complete — <title> — +XP" reward moment, shared by the
/// Gamification intro (a demo of the mechanic) and Journey Ready (the real
/// first mission the user is about to start) — showing the exact same
/// lesson/XP number in both places instead of two invented figures.
class MissionRewardCard extends StatelessWidget {
  const MissionRewardCard({
    super.key,
    required this.title,
    required this.xp,
    this.completed = true,
    this.eyebrow,
  });

  final String title;
  final int xp;
  final bool completed;

  /// Overrides the default "Mission Complete" eyebrow — Journey Ready shows
  /// this same card for an *upcoming* mission, not a completed one.
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      surface: CardSurface.reward,
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.goldenBorder.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              completed
                  ? Icons.emoji_events_rounded
                  : Icons.track_changes_rounded,
              color: AppColors.goldenBorder,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow ??
                      Translator.translate(AppStrings.missionCompleteLabel),
                  style: TextStyle(
                    color: tokens.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _XpPill(xp: xp),
        ],
      ),
    );
  }
}

class _XpPill extends StatefulWidget {
  const _XpPill({required this.xp});

  final int xp;

  @override
  State<_XpPill> createState() => _XpPillState();
}

class _XpPillState extends State<_XpPill> {
  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.goldenBorder.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.goldenBorder.withValues(alpha: 0.5),
        ),
      ),
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: reducedMotion ? widget.xp : 0, end: widget.xp),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Text(
          Translator.translate(
            AppStrings.academyXpPill,
            params: {'xp': '$value'},
          ),
          style: const TextStyle(
            color: AppColors.goldenBorder,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
