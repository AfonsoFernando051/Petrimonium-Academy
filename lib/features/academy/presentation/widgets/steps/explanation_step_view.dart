import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/core/widgets/layer_chip.dart';

class ExplanationStepView extends StatelessWidget {
  const ExplanationStepView({super.key, required this.step, this.breadcrumb});

  final ExplanationStep step;

  /// "{Module} · Lesson N of M" — derived from the real catalog by
  /// `LessonScreen`, null only if the lesson/module can't be resolved in it.
  final String? breadcrumb;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayerChip(
              label: Translator.translate(AppStrings.academyContentLabel),
              color: AppColors.neonCyan,
            ),
            if (breadcrumb != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  breadcrumb!,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: tokens.textTertiary, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Text(step.title, style: TextStyle(color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(step.body, style: TextStyle(color: tokens.textSecondary, fontSize: 15, height: 1.5)),
      ],
    );
  }
}
