import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/domain/services/mission_display_catalog.dart';

class MissionCardWidget extends StatelessWidget {
  const MissionCardWidget({super.key, required this.mission});

  final MissionStatus mission;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final info = MissionDisplayCatalog.forCode(mission.code);
    final color = mission.completed ? AppColors.positiveGreen : AppColors.neonCyan;
    final progressRatio = mission.target == 0 ? 0.0 : (mission.progress / mission.target).clamp(0.0, 1.0);

    return Container(
      width: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mission.completed
            ? AppColors.positiveGreen.withValues(alpha: 0.08)
            : tokens.surface.withValues(alpha: context.isDarkMode ? 0.4 : 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: mission.completed ? 0.5 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(mission.completed ? Icons.check_circle : info.icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  info.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tokens.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            info.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: tokens.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 5,
              backgroundColor: tokens.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mission.progress}/${mission.target}',
                style: TextStyle(color: tokens.textTertiary, fontSize: 9),
              ),
              Text('+${mission.xpReward} XP', style: TextStyle(color: color, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
