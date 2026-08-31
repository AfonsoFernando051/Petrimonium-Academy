import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';

class LessonListTile extends StatelessWidget {
  const LessonListTile({super.key, required this.lesson, required this.status, required this.onTap});

  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isLocked = status == LessonStatus.locked;
    final isCompleted = status == LessonStatus.completed;
    final accent = isCompleted ? tokens.success : AppColors.neonCyan;

    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 8),
        borderRadius: 16,
        borderColor: accent.withValues(alpha: isLocked ? 0.12 : 0.3),
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLocked ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : (isLocked ? Icons.lock_outline : Icons.play_arrow_rounded),
                      color: accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  Text(
                    Translator.translate(AppStrings.academyXpPill, params: {'xp': '${lesson.xpReward}'}),
                    style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
