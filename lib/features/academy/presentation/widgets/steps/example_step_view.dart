import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

class ExampleStepView extends StatelessWidget {
  const ExampleStepView({super.key, required this.step, this.breadcrumb});

  final ExampleStep step;

  /// "{Module} · Lesson N of M" — same breadcrumb shown on the explanation
  /// step, so the learner stays oriented across a lesson's content beats.
  final String? breadcrumb;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (breadcrumb != null) ...[
          Text(breadcrumb!, style: TextStyle(color: tokens.textTertiary, fontSize: 12)),
          const SizedBox(height: 16),
        ],
        GlassCard(
          borderColor: AppColors.goldenBorder.withValues(alpha: 0.5),
          backgroundColor: AppColors.goldenBorder.withValues(alpha: 0.05),
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Translator.translate(AppStrings.academyExampleLabel),
                style: TextStyle(
                  color: tokens.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(step.title, style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(step.body, style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
