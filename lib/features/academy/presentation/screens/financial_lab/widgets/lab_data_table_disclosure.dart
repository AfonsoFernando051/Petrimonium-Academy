import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// One row of an already-formatted [LabDataTableDisclosure] — [label] is
/// the row's leading value (e.g. a year), [values] line up with the
/// disclosure's `columnLabels` (minus the first, implicit label column).
class LabDataTableRow {
  const LabDataTableRow({required this.label, required this.values});

  final String label;
  final List<String> values;
}

/// A collapsed, expandable text rendering of a chart's series — every
/// Financial Lab chart must be understandable without relying on the chart
/// alone (a screen reader has no way to read a `BarChart`/`LineChart`/
/// `PieChart`'s bars/points/slices). One shared widget so every simulator
/// gets this for free instead of it being an afterthought per chart.
class LabDataTableDisclosure extends StatelessWidget {
  const LabDataTableDisclosure({
    super.key,
    required this.columnLabels,
    required this.rows,
  });

  /// Column headers, first one being the implicit row [LabDataTableRow.label]
  /// column (e.g. `['Ano', 'Aportes', 'Crescimento']`).
  final List<String> columnLabels;
  final List<LabDataTableRow> rows;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return GlassCard(
      borderRadius: AppRadii.lg,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 0,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          iconColor: tokens.textSecondary,
          collapsedIconColor: tokens.textSecondary,
          title: Text(
            Translator.translate(AppStrings.labDataTableDisclosureTitle),
            style: AppTextStyles.label.copyWith(
              color: tokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            _headerRow(tokens),
            for (final row in rows) _dataRow(tokens, row),
          ],
        ),
      ),
    );
  }

  Widget _headerRow(AppColorTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          for (final label in columnLabels)
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: tokens.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dataRow(AppColorTokens tokens, LabDataTableRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.label,
              style: AppTextStyles.caption.copyWith(color: tokens.textPrimary),
            ),
          ),
          for (final value in row.values)
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.caption.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
