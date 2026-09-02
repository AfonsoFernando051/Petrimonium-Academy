import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/xp_bar.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/home/domain/entities/next_action.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/domain/services/mission_display_catalog.dart';

/// Home's single primary CTA — renders whichever [NextAction]
/// `NextActionResolver` decided is currently the most important thing for
/// the user to do (`docs/PRODUCT_VISION.md` §8: "what am I learning" /
/// "what should I do next"). Same static golden glow every variant shares —
/// it should always read as "the one thing to do here", regardless of which
/// branch is showing.
class NextActionCard extends StatelessWidget {
  const NextActionCard({
    super.key,
    required this.action,
    required this.onStartLesson,
    required this.onOpenAcademy,
  });

  final NextAction action;
  final VoidCallback onStartLesson;
  final VoidCallback onOpenAcademy;

  @override
  Widget build(BuildContext context) {
    return switch (action) {
      ContinueLessonAction(
        :final lesson,
        :final moduleTitle,
        :final moduleLessonCount,
        :final moduleCompletedCount,
        :final goalLabel,
      ) =>
        _ContinueLessonContent(
          lesson: lesson,
          moduleTitle: moduleTitle,
          moduleLessonCount: moduleLessonCount,
          moduleCompletedCount: moduleCompletedCount,
          goalLabel: goalLabel,
          onStartLesson: onStartLesson,
        ),
      CompleteMissionAction(:final mission) =>
        _CompleteMissionContent(mission: mission, onStartLesson: onStartLesson, onOpenAcademy: onOpenAcademy),
      AllLessonsCompleteAction() => _AllLessonsCompleteContent(onOpenAcademy: onOpenAcademy),
    };
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.55),
      borderWidth: 1.5,
      borderRadius: 20,
      boxShadow: [
        BoxShadow(color: AppColors.goldenBorder.withValues(alpha: 0.16), blurRadius: 24, spreadRadius: 1),
      ],
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.goldenBorder, size: 16),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.goldenBorder,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _ContinueLessonContent extends StatelessWidget {
  const _ContinueLessonContent({
    required this.lesson,
    required this.moduleTitle,
    required this.moduleLessonCount,
    required this.moduleCompletedCount,
    required this.goalLabel,
    required this.onStartLesson,
  });

  final Lesson lesson;
  final String? moduleTitle;
  final int? moduleLessonCount;
  final int? moduleCompletedCount;
  final String? goalLabel;
  final VoidCallback onStartLesson;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Eyebrow(icon: Icons.flag_circle, label: Translator.translate(AppStrings.homeContinueLearningEyebrow)),
              if (moduleLessonCount != null)
                Text(
                  '$moduleLessonCount ${Translator.translate(
                    moduleLessonCount == 1 ? AppStrings.academyIntroLessonSingular : AppStrings.academyIntroLessonPlural,
                  )}',
                  style: TextStyle(color: tokens.textTertiary, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (moduleTitle != null) ...[
            Text(
              moduleTitle!,
              style: TextStyle(color: tokens.textTertiary, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            lesson.title,
            style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 19),
          ),
          const SizedBox(height: 4),
          Text(
            Translator.translate(AppStrings.academyXpToCompleteLabel, params: {'xp': '${lesson.xpReward}'}),
            style: TextStyle(color: tokens.textSecondary, fontSize: 12),
          ),
          if (goalLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              Translator.translate(AppStrings.homeContinueGoalSubtitle, params: {'goal': goalLabel!}),
              style: TextStyle(color: tokens.textTertiary, fontSize: 12),
            ),
          ],
          if (moduleLessonCount != null && moduleLessonCount! > 0 && moduleCompletedCount != null) ...[
            const SizedBox(height: 12),
            XpBar(progress: moduleCompletedCount! / moduleLessonCount!, color: AppColors.neonCyan, height: 6),
          ],
          const SizedBox(height: 16),
          GameButton(
            label: Translator.translate(AppStrings.homeContinueLearningCta),
            icon: Icons.play_arrow_rounded,
            colors: const [AppColors.neonViolet, AppColors.neonPink],
            pulse: true,
            onPressed: onStartLesson,
          ),
        ],
      ),
    );
  }
}

class _CompleteMissionContent extends StatelessWidget {
  const _CompleteMissionContent({required this.mission, required this.onStartLesson, required this.onOpenAcademy});

  final MissionStatus mission;
  final VoidCallback onStartLesson;
  final VoidCallback onOpenAcademy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final info = MissionDisplayCatalog.forCode(mission.code);
    final xpReward = mission.xpReward;

    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(icon: Icons.local_fire_department, label: Translator.translate(AppStrings.homeMissionAlmostDoneEyebrow)),
          const SizedBox(height: 10),
          Text(
            info.title,
            style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 19),
          ),
          const SizedBox(height: 4),
          Text(
            Translator.translate(AppStrings.homeMissionAlmostDoneBody, params: {'xp': '$xpReward'}),
            style: TextStyle(color: tokens.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GameButton(
            label: Translator.translate(AppStrings.homeContinueLearningCta),
            icon: Icons.play_arrow_rounded,
            colors: const [AppColors.neonViolet, AppColors.neonPink],
            pulse: true,
            onPressed: onStartLesson,
          ),
        ],
      ),
    );
  }
}

class _AllLessonsCompleteContent extends StatelessWidget {
  const _AllLessonsCompleteContent({required this.onOpenAcademy});

  final VoidCallback onOpenAcademy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: AppColors.goldenBorder, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  Translator.translate(AppStrings.homeAllLessonsCompleteTitle),
                  style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Translator.translate(AppStrings.homeAllLessonsCompleteBody),
            style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          GameButton(
            label: Translator.translate(AppStrings.homeExploreAcademyCta),
            icon: Icons.school_outlined,
            colors: const [AppColors.neonViolet, AppColors.neonPink],
            onPressed: onOpenAcademy,
          ),
        ],
      ),
    );
  }
}
