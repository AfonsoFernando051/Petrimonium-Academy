import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';

/// The pill-shaped row shown under a chart when a point/bar is touched
/// (Wealth Evolution, Wealth Evolution bars, Proventos Evolution) — same
/// padding/radius/background/accent-border chrome across all three,
/// previously three near-identical private `_TooltipSummary` widgets that
/// differed in what data they summarized. Callers own the actual content
/// (already-formatted `Text` widgets) since each chart's data shape and
/// labeling differ too much to genericize further; this widget owns only
/// the shared container styling.
class TooltipSummary extends StatelessWidget {
  const TooltipSummary({super.key, required this.accentColor, required this.children});

  final Color accentColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}
