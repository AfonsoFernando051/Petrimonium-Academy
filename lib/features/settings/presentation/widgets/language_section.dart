import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Settings → Language: pt/en/es picker. Reads [Translator.currentLanguage]
/// directly for the selected-state highlight — the parent screen already
/// rebuilds this section on every language change via its own
/// `Translator.languageNotifier` listener.
class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key, required this.sectionLabel, required this.onLanguageSelected});

  final Widget Function(String label) sectionLabel;
  final ValueChanged<String> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final languages = [
      (code: 'pt', label: Translator.translate(AppStrings.languagePt), flag: '🇧🇷'),
      (code: 'en', label: Translator.translate(AppStrings.languageEn), flag: '🇺🇸'),
      (code: 'es', label: Translator.translate(AppStrings.languageEs), flag: '🇪🇸'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel(Translator.translate(AppStrings.languageSectionTitle).toUpperCase()),
        GlassCard(
          backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
          borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
          borderRadius: AppRadii.xl,
          borderWidth: 1,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: languages.map((lang) {
              final isSelected = Translator.currentLanguage == lang.code;
              return InkWell(
                onTap: () => onLanguageSelected(lang.code),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
                  child: Row(
                    children: [
                      Text(lang.flag, style: AppTextStyles.headline),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          lang.label,
                          style: AppTextStyles.title.copyWith(
                            color: isSelected ? tokens.textPrimary : tokens.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected) Icon(Icons.check_circle, color: tokens.primary, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
