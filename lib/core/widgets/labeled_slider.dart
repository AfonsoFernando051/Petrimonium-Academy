import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';

/// A label/value row over a [Slider], with haptic feedback on drag and a
/// semantic value announced to screen readers — extracted from the
/// Financial Lab's Compound Interest simulator, the app's only prior
/// `Slider` usage, so every simulator shares one accessible input widget
/// instead of five near-identical private copies.
class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.semanticValue,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  /// What a screen reader announces for the current value — defaults to
  /// [valueLabel] (e.g. "8.0%") but can be overridden with a fuller phrase
  /// (e.g. "8 percent per year") when the compact display label alone would
  /// be ambiguous out of visual context.
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: tokens.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              valueLabel,
              style: AppTextStyles.body.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Semantics(
          label: label,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.neonCyan,
              inactiveTrackColor: tokens.textPrimary.withValues(alpha: 0.08),
              thumbColor: AppColors.neonCyan,
              overlayColor: AppColors.neonCyan.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              // Overrides the raw numeric announcement ("8.0") a screen
              // reader would otherwise read, with the same formatted label
              // shown visually (e.g. "8.0%") — falls back to a caller-
              // supplied fuller phrase when the compact label alone would
              // be ambiguous out of visual context.
              semanticFormatterCallback: (_) => semanticValue ?? valueLabel,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
