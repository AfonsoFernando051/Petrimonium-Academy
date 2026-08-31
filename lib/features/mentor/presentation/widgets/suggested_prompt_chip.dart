import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// A tappable suggested-question chip shown when the conversation is empty,
/// so a new user isn't staring at a blank input field.
class SuggestedPromptChip extends StatelessWidget {
  const SuggestedPromptChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
