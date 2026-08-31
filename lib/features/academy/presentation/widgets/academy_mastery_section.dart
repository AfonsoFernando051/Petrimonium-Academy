import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';
import 'package:petrimonium/features/academy/presentation/widgets/mastery_bar_row.dart';

/// `AcademyHomeScreen`'s Progress + Mastery breakdown — one [MasteryBarRow]
/// per school that has real content available (an empty 0% row for a
/// `comingSoon` school isn't informative, so the caller filters those out
/// before passing [schools] in).
///
/// Deliberately chrome-free (no card/border) — same reasoning as
/// [AcademyLevelHeader]: this is supporting detail below
/// `AcademyContinueCard`'s primary CTA, not a second decision point that
/// should visually compete with it.
class AcademyMasterySection extends StatelessWidget {
  const AcademyMasterySection({
    super.key,
    required this.schools,
    required this.masteryFor,
    required this.realMasteryFor,
    required this.masteryTierFor,
  });

  final List<School> schools;

  /// Progress (completion) percent per school.
  final double Function(School school) masteryFor;

  /// Real, performance-based Mastery percent per school.
  final double Function(School school) realMasteryFor;
  final MasteryTier Function(School school) masteryTierFor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translator.translate(AppStrings.academyMasterySectionLabel),
          style: AppTextStyles.caption.copyWith(
            color: tokens.primary.withValues(alpha: 0.6),
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final school in schools)
          MasteryBarRow(
            school: school,
            percent: masteryFor(school),
            masteryPercent: realMasteryFor(school),
            masteryTier: masteryTierFor(school),
          ),
      ],
    );
  }
}
