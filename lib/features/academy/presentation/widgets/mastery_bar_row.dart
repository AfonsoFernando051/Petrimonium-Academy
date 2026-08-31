import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';
import 'package:petrimonium/features/academy/presentation/widgets/mastery_tier_presentation.dart';

/// One row of the Academy home's "Your Mastery" section — a school's icon,
/// title, Progress bar (completion, `AcademyController.masteryFor`) and a
/// real Mastery tier badge (`AcademyController.masteryTierFor`/
/// `realMasteryFor`). Progress and Mastery are shown as two distinct
/// numbers, never merged into one — a school can be 100% complete while
/// still only `applying` if some lessons were finished with a wrong answer
/// (`docs/ACADEMY_ENGINE.md` §3d). Only shown for schools with real content.
class MasteryBarRow extends StatelessWidget {
  const MasteryBarRow({
    super.key,
    required this.school,
    required this.percent,
    required this.masteryPercent,
    required this.masteryTier,
  });

  final School school;

  /// Progress (completion) percent, 0.0-1.0.
  final double percent;

  /// Real Mastery percent, 0.0-1.0 — distinct from [percent].
  final double masteryPercent;
  final MasteryTier masteryTier;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final tierColor = MasteryTierPresentation.color(masteryTier);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(school.icon, size: 16, color: tokens.textSecondary),
              const SizedBox(width: 8),
              SizedBox(
                width: 116,
                child: Text(
                  school.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tokens.textPrimary, fontSize: 11, fontWeight: FontWeight.w600, height: 1.15),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: AcademyProgressBar(progress: percent, height: 6)),
              const SizedBox(width: 10),
              SizedBox(
                width: 34,
                child: Text(
                  '${(percent * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: tokens.textTertiary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 124),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tierColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Text(
                    Translator.translate(MasteryTierPresentation.labelKey(masteryTier)),
                    style: TextStyle(color: tierColor, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${Translator.translate(AppStrings.academyRealMasteryLabel)} · ${(masteryPercent * 100).round()}%',
                  style: TextStyle(color: tokens.textTertiary, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
