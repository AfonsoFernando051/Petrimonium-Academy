import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';

class AchievementCardWidget extends StatelessWidget {
  const AchievementCardWidget({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final color = achievement.unlocked ? AppColors.goldenBorder : tokens.textTertiary;

    return Container(
      width: 108,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? AppColors.goldenBorder.withValues(alpha: 0.1)
            : tokens.surface.withValues(alpha: context.isDarkMode ? 0.4 : 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: achievement.unlocked ? 0.5 : 0.15)),
        boxShadow: achievement.unlocked
            ? [BoxShadow(color: AppColors.goldenBorder.withValues(alpha: 0.25), blurRadius: 10, spreadRadius: 1)]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achievement.unlocked ? achievement.icon : Icons.lock_outline,
            color: achievement.unlocked ? AppColors.goldenBorder : tokens.textTertiary,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: achievement.unlocked ? tokens.textPrimary : tokens.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+${achievement.xpReward} XP',
            style: TextStyle(color: achievement.unlocked ? AppColors.goldenBorder : tokens.textTertiary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
