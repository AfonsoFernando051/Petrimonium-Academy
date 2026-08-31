import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';

/// A school-level journey node — the Academy home's top-level list item, one
/// visual step up from [ModuleCard]. Same visual language and status
/// treatment (lock/progress/reward states), applied to a [SchoolStatus]
/// instead of a [ModuleStatus].
class SchoolCard extends StatelessWidget {
  const SchoolCard({
    super.key,
    required this.school,
    required this.status,
    required this.masteryPercent,
    required this.onTap,
    this.missingPrerequisites = const [],
  });

  final School school;
  final SchoolStatus status;
  final double masteryPercent;
  final VoidCallback? onTap;

  /// Titles of the prerequisite school(s) still missing — only meaningful
  /// when [status] is [SchoolStatus.locked] on a real prerequisite (not
  /// [SchoolStatus.comingSoon], which has no prerequisite to name). Renders
  /// as "Complete X first" instead of an unexplained lock icon.
  final List<String> missingPrerequisites;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isLocked = status == SchoolStatus.comingSoon || status == SchoolStatus.locked;

    final accentColor = switch (status) {
      SchoolStatus.completed => tokens.success,
      SchoolStatus.inProgress => AppColors.neonPurple,
      SchoolStatus.available => AppColors.neonCyan,
      SchoolStatus.locked => tokens.textTertiary,
      SchoolStatus.comingSoon => tokens.textTertiary,
    };
    final cardSurface = switch (status) {
      SchoolStatus.completed => CardSurface.reward,
      SchoolStatus.inProgress => CardSurface.active,
      SchoolStatus.available => CardSurface.standard,
      SchoolStatus.locked => CardSurface.disabled,
      SchoolStatus.comingSoon => CardSurface.disabled,
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
                        child: Icon(isLocked ? Icons.lock_outline : school.icon, color: accentColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              school.title,
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
                    school.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tokens.textSecondary, fontSize: 12, height: 1.35),
                  ),
                  if (!isLocked) ...[
                    const SizedBox(height: 12),
                    AcademyProgressBar(progress: masteryPercent),
                    const SizedBox(height: 6),
                    Text(
                      Translator.translate(
                        AppStrings.academyMasteryPercentLabel,
                        params: {'percent': '${(masteryPercent * 100).round()}'},
                      ),
                      style: TextStyle(color: tokens.textTertiary, fontSize: 11),
                    ),
                  ] else if (status == SchoolStatus.locked && missingPrerequisites.isNotEmpty) ...[
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

  String _statusLabel(SchoolStatus status) {
    return switch (status) {
      SchoolStatus.completed => Translator.translate(AppStrings.academyModuleStatusCompleted),
      SchoolStatus.inProgress => Translator.translate(AppStrings.academyModuleStatusInProgress),
      SchoolStatus.available => Translator.translate(AppStrings.academyModuleStatusAvailable),
      SchoolStatus.locked => Translator.translate(AppStrings.academyModuleStatusLocked),
      SchoolStatus.comingSoon => Translator.translate(AppStrings.academyModuleStatusComingSoon),
    };
  }
}
