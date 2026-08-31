import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/pet/presentation/companion/enums/pet_speech_bubble_state.dart';

/// Design tokens and visual styling parameters for each [PetSpeechBubbleState].
class PetSpeechBubbleStateStyle {
  const PetSpeechBubbleStateStyle({
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.surfaceGradient,
    required this.borderColor,
    required this.glowColor,
    required this.badgeIcon,
    required this.badgeTitleKey,
  });

  final Color primaryAccent;
  final Color secondaryAccent;
  final Gradient surfaceGradient;
  final Color borderColor;
  final Color glowColor;
  final IconData badgeIcon;
  final String badgeTitleKey;

  /// Resolves the complete visual style for a given [state] and dark/light [context].
  factory PetSpeechBubbleStateStyle.forState(
    PetSpeechBubbleState state,
    BuildContext context,
  ) {
    final isDark = context.isDarkMode;
    final tokens = context.colors;

    switch (state) {
      case PetSpeechBubbleState.idle:
        return PetSpeechBubbleStateStyle(
          primaryAccent: AppColors.neonCyan,
          secondaryAccent: const Color(0xFF00B4D8),
          surfaceGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    tokens.surfaceElevated.withValues(alpha: 0.92),
                    const Color(0xFF0D1F2D).withValues(alpha: 0.94),
                  ]
                : [
                    tokens.surfaceElevated,
                    const Color(0xFFE0F7FA),
                  ],
          ),
          borderColor: AppColors.neonCyan.withValues(alpha: isDark ? 0.65 : 0.8),
          glowColor: AppColors.neonCyan.withValues(alpha: isDark ? 0.22 : 0.15),
          badgeIcon: Icons.chat_bubble_outline_rounded,
          badgeTitleKey: 'COMPANION',
        );

      case PetSpeechBubbleState.guidance:
        const indigoAccent = Color(0xFF6C5CE7);
        const blueAccent = Color(0xFF0984E3);
        return PetSpeechBubbleStateStyle(
          primaryAccent: indigoAccent,
          secondaryAccent: blueAccent,
          surfaceGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    tokens.surfaceElevated.withValues(alpha: 0.92),
                    const Color(0xFF191338).withValues(alpha: 0.94),
                  ]
                : [
                    tokens.surfaceElevated,
                    const Color(0xFFEDE7F6),
                  ],
          ),
          borderColor: indigoAccent.withValues(alpha: isDark ? 0.7 : 0.85),
          glowColor: indigoAccent.withValues(alpha: isDark ? 0.25 : 0.15),
          badgeIcon: Icons.lightbulb_outline_rounded,
          badgeTitleKey: 'DICA DO PET',
        );

      case PetSpeechBubbleState.success:
        const emeraldAccent = Color(0xFF10B981);
        const mintAccent = Color(0xFF34D399);
        return PetSpeechBubbleStateStyle(
          primaryAccent: emeraldAccent,
          secondaryAccent: mintAccent,
          surfaceGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    tokens.surfaceElevated.withValues(alpha: 0.92),
                    const Color(0xFF062C1B).withValues(alpha: 0.94),
                  ]
                : [
                    tokens.surfaceElevated,
                    const Color(0xFFE8F5E9),
                  ],
          ),
          borderColor: emeraldAccent.withValues(alpha: isDark ? 0.75 : 0.85),
          glowColor: emeraldAccent.withValues(alpha: isDark ? 0.28 : 0.18),
          badgeIcon: Icons.auto_awesome_rounded,
          badgeTitleKey: 'CONQUISTA',
        );

      case PetSpeechBubbleState.encouragement:
        const coralAccent = Color(0xFFFF6B6B);
        const peachAccent = Color(0xFFFF8E53);
        return PetSpeechBubbleStateStyle(
          primaryAccent: coralAccent,
          secondaryAccent: peachAccent,
          surfaceGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    tokens.surfaceElevated.withValues(alpha: 0.92),
                    const Color(0xFF2C1217).withValues(alpha: 0.94),
                  ]
                : [
                    tokens.surfaceElevated,
                    const Color(0xFFFFEBEE),
                  ],
          ),
          borderColor: coralAccent.withValues(alpha: isDark ? 0.75 : 0.85),
          glowColor: coralAccent.withValues(alpha: isDark ? 0.25 : 0.15),
          badgeIcon: Icons.favorite_border_rounded,
          badgeTitleKey: 'VAMOS JUNTOS',
        );

      case PetSpeechBubbleState.milestone:
        const purpleAccent = Color(0xFF9D4EDD);
        const goldAccent = Color(0xFFFFD700);
        return PetSpeechBubbleStateStyle(
          primaryAccent: purpleAccent,
          secondaryAccent: goldAccent,
          surfaceGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF240046).withValues(alpha: 0.94),
                    const Color(0xFF10002B).withValues(alpha: 0.96),
                  ]
                : [
                    tokens.surfaceElevated,
                    const Color(0xFFF3E5F5),
                  ],
          ),
          borderColor: goldAccent.withValues(alpha: isDark ? 0.85 : 0.9),
          glowColor: purpleAccent.withValues(alpha: isDark ? 0.35 : 0.22),
          badgeIcon: Icons.workspace_premium_rounded,
          badgeTitleKey: 'EVOLUÇÃO',
        );

      case PetSpeechBubbleState.attention:
        const amberAccent = Color(0xFFF59E0B);
        const orangeAccent = Color(0xFFD97706);
        return PetSpeechBubbleStateStyle(
          primaryAccent: amberAccent,
          secondaryAccent: orangeAccent,
          surfaceGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    tokens.surfaceElevated.withValues(alpha: 0.92),
                    const Color(0xFF2A1B00).withValues(alpha: 0.94),
                  ]
                : [
                    tokens.surfaceElevated,
                    const Color(0xFFFFF8E1),
                  ],
          ),
          borderColor: amberAccent.withValues(alpha: isDark ? 0.8 : 0.9),
          glowColor: amberAccent.withValues(alpha: isDark ? 0.28 : 0.18),
          badgeIcon: Icons.notifications_active_rounded,
          badgeTitleKey: 'ATENÇÃO',
        );
    }
  }
}
