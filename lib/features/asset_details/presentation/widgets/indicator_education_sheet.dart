import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_indicator.dart';
import 'package:petrimonium/features/asset_details/domain/services/indicator_education_catalog.dart';

/// Educational bottom sheet shown when the user taps an indicator.
/// Follows the three-part structure:
/// 1. What is it?
/// 2. Why does it matter?
/// 3. Important caveat
///
/// Optionally shows a pet dialogue and action buttons.
class IndicatorEducationSheet extends StatelessWidget {
  const IndicatorEducationSheet({super.key, required this.indicator});

  final AssetIndicator indicator;

  @override
  Widget build(BuildContext context) {
    final explanation = IndicatorEducationCatalog.getExplanation(indicator.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        final tokens = context.colors;
        return Container(
          decoration: BoxDecoration(
            color: tokens.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // ── Drag handle ────────────────────────────────────
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: tokens.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Indicator header ───────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      indicator.label,
                      style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    indicator.value ?? '--',
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (explanation != null) ...[
                // ── What is it? ──────────────────────────────────
                _EducationSection(
                  icon: Icons.school_outlined,
                  title: explanation.title,
                  content: explanation.definition,
                  accentColor: AppColors.neonCyan,
                ),
                const SizedBox(height: 16),

                // ── Why does it matter? ──────────────────────────
                _EducationSection(
                  icon: Icons.lightbulb_outline,
                  title: 'Por que importa?',
                  content: explanation.whyItMatters,
                  accentColor: AppColors.goldenBorder,
                ),
                const SizedBox(height: 16),

                // ── Important caveat ─────────────────────────────
                _EducationSection(
                  icon: Icons.warning_amber_outlined,
                  title: 'Importante',
                  content: explanation.caveat,
                  accentColor: context.colors.warning,
                ),

                // ── Pet dialogue ─────────────────────────────────
                if (explanation.petDialogue != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.pets, color: AppColors.neonCyan, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            explanation.petDialogue!,
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else
                Text(
                  'Explicação educacional em breve.',
                  style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _EducationSection extends StatelessWidget {
  const _EducationSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accentColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}
