import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';

/// One dot+label pair in a [ChartLegend].
class ChartLegendItem {
  const ChartLegendItem({required this.color, required this.label});

  final Color color;
  final String label;
}

/// Small "● Label   ● Label" row used above the portfolio's evolution
/// charts (Wealth, Wealth-as-bars, Proventos) — previously three
/// structurally-identical private `_Legend` widgets that differed only in
/// which colors/labels they hardcoded.
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items});

  final List<ChartLegendItem> items;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm + 2),
          _dot(items[i].color),
          const SizedBox(width: AppSpacing.xs),
          Text(items[i].label, style: AppTextStyles.caption.copyWith(color: tokens.textSecondary)),
        ],
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
