import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';

/// `PetConfigurationScreen`'s name entry: free-text field plus quick-pick
/// suggestion chips. State (the controller, whether to show the "required"
/// error) stays owned by the screen since it feeds `_handleContinue`
/// directly — this widget is a thin, stateless presentation of it.
class PetNameField extends StatelessWidget {
  const PetNameField({
    super.key,
    required this.controller,
    required this.showError,
    required this.suggestions,
    required this.onChanged,
    required this.onSuggestionSelected,
  });

  final TextEditingController controller;
  final bool showError;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Translator.translate(AppStrings.namePetPrompt),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.textPrimary),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: Translator.translate(AppStrings.namePetHint),
            hintStyle: TextStyle(color: tokens.textTertiary),
            filled: true,
            fillColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
            errorText: showError ? Translator.translate(AppStrings.namePetRequiredError) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md + 2),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md + 2),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md + 2),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: suggestions.map((name) {
            final isSelected = controller.text == name;
            return ChoiceChip(
              label: Text(name),
              selected: isSelected,
              onSelected: (_) => onSuggestionSelected(name),
              labelStyle: TextStyle(
                color: isSelected ? tokens.textPrimary : tokens.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: tokens.textPrimary.withValues(alpha: 0.06),
              selectedColor: AppColors.neonCyan.withValues(alpha: 0.25),
              side: BorderSide(color: isSelected ? AppColors.neonCyan : tokens.textPrimary.withValues(alpha: 0.15)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
