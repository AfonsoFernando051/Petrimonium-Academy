import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// `AcademyHomeScreen`'s entry point into the Financial Lab
/// (`docs/ACADEMY_ENGINE.md` §3d, brief §27) — a simulation sandbox, kept
/// visually distinct (violet/gold, "lab" iconography) from the curriculum
/// cards above it so it reads as a different kind of activity: explore,
/// not graded progress.
class FinancialLabEntryCard extends StatelessWidget {
  const FinancialLabEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: GlassCard(
        borderColor: AppColors.neonViolet.withValues(alpha: 0.35),
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.neonViolet, AppColors.goldenBorder]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.science_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Translator.translate(AppStrings.financialLabTitle),
                      style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Translator.translate(AppStrings.financialLabSubtitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tokens.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.textTertiary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
