import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/module_chip.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';

/// Home's "how is my knowledge developing" glance
/// (`docs/PRODUCT_VISION.md` §8): a compact, tappable row of module status
/// chips — real derived data (`AcademyController.modules`/`.statusFor`,
/// the same `AcademyProgressCalculator` the full Academy screen uses), just
/// condensed instead of duplicating `AcademyHomeScreen`'s full module list.
class KnowledgeMapStrip extends StatelessWidget {
  const KnowledgeMapStrip({
    super.key,
    required this.modules,
    required this.statusFor,
    required this.completedLessonCountFor,
    required this.onTapModule,
    required this.onViewAll,
  });

  final List<AcademyModule> modules;
  final ModuleStatus Function(AcademyModule module) statusFor;
  final int Function(AcademyModule module) completedLessonCountFor;
  final void Function(AcademyModule module) onTapModule;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final sorted = [...modules]..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Translator.translate(AppStrings.homeKnowledgeMapLabel),
              style: TextStyle(color: tokens.primary.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                Translator.translate(AppStrings.homeViewFullAcademyCta),
                style: const TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => ModuleChip(
              module: sorted[i],
              layout: ModuleChipLayout.vertical,
              status: statusFor(sorted[i]),
              completedLessons: completedLessonCountFor(sorted[i]),
              onTap: () {
                HapticFeedback.selectionClick();
                onTapModule(sorted[i]);
              },
            ),
          ),
        ),
      ],
    );
  }
}
