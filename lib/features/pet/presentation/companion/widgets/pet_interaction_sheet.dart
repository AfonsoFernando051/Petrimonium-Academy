import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/rive/pet_rive_companion.dart';

/// Tapping the companion header opens this — a lightweight, structured menu
/// ("Learn / Portfolio / Progress") rather than a chatbot, matching the
/// product spec's "keep the first implementation lightweight" guidance.
/// Selecting an option closes the sheet and reports the destination
/// [PetContext] via [PetInteractionSheet.onSelect]; the host screen owns
/// what "go there" actually means (switch tab, push a route).
class PetInteractionSheet extends StatelessWidget {
  const PetInteractionSheet({super.key, required this.controller});

  final PetCompanionController controller;

  void _select(BuildContext context, PetContext destination) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(destination);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final petName = controller.mascotController.profile.name;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Container(
          decoration: BoxDecoration(
            color: tokens.surfaceElevated.withValues(
              alpha: context.isDarkMode ? 0.92 : 0.98,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.15),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonCyan.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: PetRiveCompanion(
                          controller: controller.mascotController,
                          size: 40,
                          interactive: false,
                          interacting: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            petName?.isNotEmpty == true
                                ? petName!
                                : Translator.translate(
                                    AppStrings.companionInteractionTitle,
                                  ),
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            Translator.translate(
                              AppStrings.companionInteractionSubtitle,
                            ),
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _InteractionOption(
                  icon: Icons.school_outlined,
                  label: Translator.translate(
                    AppStrings.companionInteractionLearn,
                  ),
                  onTap: () => _select(context, PetContext.academy),
                ),
                const SizedBox(height: 10),
                _InteractionOption(
                  icon: Icons.diamond_outlined,
                  label: Translator.translate(
                    AppStrings.companionInteractionPortfolio,
                  ),
                  onTap: () => _select(context, PetContext.portfolio),
                ),
                const SizedBox(height: 10),
                _InteractionOption(
                  icon: Icons.person_outline,
                  label: Translator.translate(
                    AppStrings.companionInteractionProgress,
                  ),
                  onTap: () => _select(context, PetContext.profile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractionOption extends StatelessWidget {
  const _InteractionOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: tokens.surface.withValues(
              alpha: context.isDarkMode ? 0.4 : 0.7,
            ),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.neonCyan, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
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
