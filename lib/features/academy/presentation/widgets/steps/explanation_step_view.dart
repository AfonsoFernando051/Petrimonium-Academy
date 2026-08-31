import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

class ExplanationStepView extends StatelessWidget {
  const ExplanationStepView({super.key, required this.step});

  final ExplanationStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lightbulb_outline, color: AppColors.neonCyan, size: 32),
        const SizedBox(height: 16),
        Text(step.title, style: TextStyle(color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(step.body, style: TextStyle(color: tokens.textSecondary, fontSize: 15, height: 1.5)),
      ],
    );
  }
}
