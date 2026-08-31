import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Two call sites needed a "module icon + title" chip and had independently
/// hand-rolled it: onboarding's Academy preview (a static grid, no
/// status/progress) and Home's Knowledge Map strip (status-aware — accent
/// color, locked state, completion badge, progress fraction). [layout]
/// preserves both existing looks under one widget instead of forcing a
/// visual redesign onto either call site.
enum ModuleChipLayout {
  /// Icon-box + title in a row — onboarding's static preview grid.
  horizontal,

  /// Icon + title + optional progress stacked in a compact card — Home's
  /// scrollable status strip.
  vertical,
}

class ModuleChip extends StatelessWidget {
  const ModuleChip({
    super.key,
    required this.module,
    this.layout = ModuleChipLayout.horizontal,
    this.status,
    this.completedLessons = 0,
    this.onTap,
  });

  final AcademyModule module;
  final ModuleChipLayout layout;

  /// Only meaningful for [ModuleChipLayout.vertical] — `null` (onboarding's
  /// preview) renders a plain, unaccented chip.
  final ModuleStatus? status;
  final int completedLessons;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return layout == ModuleChipLayout.vertical ? _buildVertical(context) : _buildHorizontal(context);
  }

  Widget _buildHorizontal(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.sm + 2),
            ),
            child: Icon(module.icon, color: AppColors.neonCyan, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              module.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tokens.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.15),
            ),
          ),
        ],
      ),
    );
  }

  Color _accentFor(ModuleStatus status) => switch (status) {
        ModuleStatus.completed => AppColors.goldenBorder,
        ModuleStatus.inProgress => AppColors.neonViolet,
        ModuleStatus.available => AppColors.neonCyan,
        ModuleStatus.locked => Colors.transparent,
        ModuleStatus.comingSoon => Colors.transparent,
      };

  Widget _buildVertical(BuildContext context) {
    final tokens = context.colors;
    final status = this.status ?? ModuleStatus.available;
    final accent = _accentFor(status);
    final locked = status == ModuleStatus.comingSoon || status == ModuleStatus.locked;

    return SizedBox(
      width: 84,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: GlassCard(
            surface: locked ? CardSurface.disabled : CardSurface.standard,
            borderColor: locked ? tokens.border : accent.withValues(alpha: 0.5),
            borderRadius: AppRadii.lg,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2, horizontal: AppSpacing.xs + 2),
            child: Opacity(
              opacity: locked ? 0.5 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(module.icon, color: locked ? tokens.textTertiary : accent, size: 22),
                      if (status == ModuleStatus.completed)
                        const Positioned(
                          right: -2,
                          top: -2,
                          child: Icon(Icons.check_circle, color: AppColors.goldenBorder, size: 12),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    module.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tokens.textPrimary, fontSize: 9.5, fontWeight: FontWeight.w600, height: 1.15),
                  ),
                  if (status == ModuleStatus.inProgress) ...[
                    const SizedBox(height: 1),
                    Text(
                      '$completedLessons/${module.lessonIds.length}',
                      style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w600, height: 1.0),
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
}
