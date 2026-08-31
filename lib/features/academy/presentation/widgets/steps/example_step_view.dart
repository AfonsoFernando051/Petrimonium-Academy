import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

class ExampleStepView extends StatelessWidget {
  const ExampleStepView({super.key, required this.step});

  final ExampleStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.calculate_outlined, color: AppColors.neonPurple, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(step.title, style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          borderColor: AppColors.neonPurple.withValues(alpha: 0.3),
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Text(step.body, style: TextStyle(color: tokens.textPrimary, fontSize: 14, height: 1.5)),
        ),
      ],
    );
  }
}
