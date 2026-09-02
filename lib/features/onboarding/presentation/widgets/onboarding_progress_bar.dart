import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// The onboarding narrative arc's shared progress indicator — a linear
/// track filled to [step]/[total] with the brand gradient, plus a "step/
/// total" fraction label, matching the Notion mockup exactly (replaces an
/// earlier dot-carousel indicator that didn't match any mockup).
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final fraction = total == 0 ? 0.0 : (step / total).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: tokens.border),
                  FractionallySizedBox(
                    widthFactor: fraction,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.brandGradient),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$step/$total',
          style: TextStyle(color: tokens.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
