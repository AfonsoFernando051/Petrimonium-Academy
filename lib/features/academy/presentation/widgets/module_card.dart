import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.status,
    required this.completedLessons,
    required this.onTap,
    this.missingPrerequisites = const [],
  });

  final AcademyModule module;
  final ModuleStatus status;
  final int completedLessons;
  final VoidCallback? onTap;

  /// Titles of the prerequisite module(s) still missing — only meaningful
  /// when [status] is [ModuleStatus.locked] on a real prerequisite (not
  /// [ModuleStatus.comingSoon], which has no prerequisite to name). Renders
  /// as "Complete X first" instead of an unexplained lock icon.
  final List<String> missingPrerequisites;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isLocked = status == ModuleStatus.comingSoon || status == ModuleStatus.locked;
    final totalLessons = module.lessonIds.length;
    final progress = totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

    // `inProgress` (the user's "current step") gets the brand purple
    // treatment so it's visually dominant against merely-`available`
    // modules, which stay a quieter cyan — otherwise the two states looked
    // identical apart from a text label.
    final accentColor = switch (status) {
      ModuleStatus.completed => tokens.success,
      ModuleStatus.inProgress => AppColors.neonPurple,
      ModuleStatus.available => AppColors.neonCyan,
      ModuleStatus.locked => tokens.textTertiary,
      ModuleStatus.comingSoon => tokens.textTertiary,
    };
    final cardSurface = switch (status) {
      ModuleStatus.completed => CardSurface.reward,
      ModuleStatus.inProgress => CardSurface.active,
      ModuleStatus.available => CardSurface.standard,
      ModuleStatus.locked => CardSurface.disabled,
      ModuleStatus.comingSoon => CardSurface.disabled,
    };

    return Opacity(
      opacity: isLocked ? 0.65 : 1.0,
      child: GlassCard(
        surface: cardSurface,
        borderColor: context.isDarkMode ? accentColor.withValues(alpha: isLocked ? 0.15 : 0.35) : null,
        borderRadius: 20,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLocked ? null : onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(isLocked ? Icons.lock_outline : module.icon, color: accentColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module.title,
                              style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _statusLabel(status),
                              style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    module.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tokens.textSecondary, fontSize: 12, height: 1.35),
                  ),
                  if (!isLocked) ...[
                    const SizedBox(height: 12),
                    AcademyProgressBar(progress: progress),
                    const SizedBox(height: 6),
                    Text(
                      Translator.translate(
                        AppStrings.academyLessonsProgressLabel,
                        params: {'completed': '$completedLessons', 'total': '$totalLessons'},
                      ),
                      style: TextStyle(color: tokens.textTertiary, fontSize: 11),
                    ),
                  ] else if (status == ModuleStatus.locked && missingPrerequisites.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 13, color: tokens.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            Translator.translate(
                              AppStrings.academyLockedPrerequisiteLabel,
                              params: {'name': missingPrerequisites.join(', ')},
                            ),
                            style: TextStyle(color: tokens.textTertiary, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(ModuleStatus status) {
    return switch (status) {
      ModuleStatus.completed => Translator.translate(AppStrings.academyModuleStatusCompleted),
      ModuleStatus.inProgress => Translator.translate(AppStrings.academyModuleStatusInProgress),
      ModuleStatus.available => Translator.translate(AppStrings.academyModuleStatusAvailable),
      ModuleStatus.locked => Translator.translate(AppStrings.academyModuleStatusLocked),
      ModuleStatus.comingSoon => Translator.translate(AppStrings.academyModuleStatusComingSoon),
    };
  }
}
