import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

class SummaryStepView extends StatelessWidget {
  const SummaryStepView({super.key, required this.step});

  final SummaryStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.fact_check_outlined, color: AppColors.goldenBorder, size: 32),
        const SizedBox(height: 16),
        Text(step.title, style: TextStyle(color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        for (final takeaway in step.takeaways)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: AppColors.goldenBorder, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(takeaway, style: TextStyle(color: tokens.textSecondary, fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
