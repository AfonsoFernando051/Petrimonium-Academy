import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';

/// Home's "how is my knowledge developing" glance
/// (`docs/PRODUCT_VISION.md` §8): a vertical, tappable list of module rows —
/// real derived data (`AcademyController.modules`/`.statusFor`, the same
/// `AcademyProgressCalculator` the full Academy screen uses).
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
        for (final module in sorted)
          _ModuleRow(
            module: module,
            status: statusFor(module),
            completedLessons: completedLessonCountFor(module),
            onTap: () {
              HapticFeedback.selectionClick();
              onTapModule(module);
            },
          ),
      ],
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.module,
    required this.status,
    required this.completedLessons,
    required this.onTap,
  });

  final AcademyModule module;
  final ModuleStatus status;
  final int completedLessons;
  final VoidCallback onTap;

  bool get _active => status == ModuleStatus.available || status == ModuleStatus.inProgress;
  bool get _locked => status == ModuleStatus.comingSoon || status == ModuleStatus.locked;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final subtitle = status == ModuleStatus.completed
        ? Translator.translate(AppStrings.academyModuleStatusCompleted)
        : '$completedLessons/${module.lessonIds.length}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _locked ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Opacity(
            opacity: _locked ? 0.5 : 1.0,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _active ? const LinearGradient(colors: AppColors.brandGradient) : null,
                    color: _active ? null : tokens.textPrimary.withValues(alpha: 0.08),
                  ),
                  child: Icon(
                    status == ModuleStatus.completed ? Icons.check_rounded : module.icon,
                    color: _active || status == ModuleStatus.completed ? Colors.white : tokens.textTertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    module.title,
                    style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(subtitle, style: TextStyle(color: tokens.textTertiary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
