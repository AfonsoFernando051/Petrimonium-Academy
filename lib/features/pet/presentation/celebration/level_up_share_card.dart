import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/game/domain/entities/player_level.dart';

/// The self-contained, capturable visual for social sharing (Instagram
/// story/feed, WhatsApp, etc.) — see `LevelUpCelebrationOverlay`, the only
/// current caller, which wraps this in a `RepaintBoundary` and hands the
/// rendered PNG to `share_plus`.
///
/// Deliberately static (no animation, no `BackdropFilter`): it must look
/// right the instant it's rasterized to an image, and a blur that reads
/// nothing behind it (there's no live background to sample offscreen)
/// would just look wrong — so this paints its own opaque gradient instead
/// of reusing `GlassCard`/`CosmicBackground`.
class LevelUpShareCard extends StatelessWidget {
  const LevelUpShareCard({
    super.key,
    required this.petImagePath,
    required this.playerLevel,
    required this.totalXp,
    this.isLevelUp = false,
  });

  final String petImagePath;
  final PlayerLevel playerLevel;
  final int totalXp;

  /// Whether this share was triggered by a fresh level-up — shows the
  /// "Subiu de nível!" badge. `false` for a plain "share my current
  /// progress" capture.
  final bool isLevelUp;

  @override
  Widget build(BuildContext context) {
    // Height-by-content rather than a fixed aspect ratio: a locked ratio
    // (e.g. Instagram's 4:5) risked clipping real content whenever a
    // longer translation (this card ships pt/en/es) wrapped an extra line
    // — every social app happily accepts/crops a tall rectangle, so there's
    // nothing gained by forcing an exact ratio here.
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.spacePurple, AppColors.spaceDark, AppColors.spaceBlue],
        ),
        border: Border.all(color: AppColors.goldenBorder.withValues(alpha: 0.6), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _SparkleField(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(),
                const SizedBox(height: 20),
                _PetPortrait(imagePath: petImagePath),
                const SizedBox(height: 20),
                if (isLevelUp) ...[
                  _LevelUpBadge(),
                  const SizedBox(height: 8),
                ],
                Text(
                  Translator.translate(
                    AppStrings.shareProgressLevelLabel,
                    params: {'level': '${playerLevel.level}'},
                  ),
                  style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 32),
                ),
                const SizedBox(height: 10),
                _XpProgressBar(playerLevel: playerLevel),
                const SizedBox(height: 8),
                Text(
                  Translator.translate(
                    AppStrings.shareProgressXpToNextLabel,
                    params: {
                      'current': '${playerLevel.xpIntoLevel}',
                      'total': '${playerLevel.xpForNextLevel}',
                    },
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(color: AppColors.subtleText),
                ),
                const SizedBox(height: 4),
                Text(
                  Translator.translate(AppStrings.shareProgressXpTotalLabel, params: {'xp': '$totalXp'}),
                  style: AppTextStyles.bodyEmphasis.copyWith(color: AppColors.goldenBorder),
                ),
                const SizedBox(height: 20),
                _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.rocket_launch, color: AppColors.neonCyan, size: 22),
        const SizedBox(width: 8),
        Text(
          'Invest Game',
          style: AppTextStyles.title.copyWith(color: Colors.white, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class _PetPortrait extends StatelessWidget {
  const _PetPortrait({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: AppColors.brandGradient),
        boxShadow: [BoxShadow(color: AppColors.goldenBorder.withValues(alpha: 0.45), blurRadius: 30, spreadRadius: 2)],
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Container(
          color: AppColors.spaceDark,
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _LevelUpBadge extends StatelessWidget {
  const _LevelUpBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.brandGradient),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        Translator.translate(AppStrings.shareProgressLevelUpBadge).toUpperCase(),
        style: AppTextStyles.label.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }
}

class _XpProgressBar extends StatelessWidget {
  const _XpProgressBar({required this.playerLevel});

  final PlayerLevel playerLevel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        width: 200,
        height: 10,
        child: Stack(
          children: [
            Container(color: Colors.white.withValues(alpha: 0.12)),
            FractionallySizedBox(
              widthFactor: playerLevel.progress,
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.brandGradient)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Translator.translate(AppStrings.shareProgressTagline),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          Translator.translate(AppStrings.shareProgressCta),
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.subtleText),
        ),
      ],
    );
  }
}

/// A handful of static sparkle icons scattered around the card — decorative
/// only, deliberately not animated (see class doc on why this card doesn't
/// animate).
class _SparkleField extends StatelessWidget {
  const _SparkleField();

  static const List<Alignment> _positions = [
    Alignment(-0.85, -0.8),
    Alignment(0.8, -0.7),
    Alignment(-0.75, 0.85),
    Alignment(0.85, 0.75),
    Alignment(0.0, -0.92),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final position in _positions)
          Align(
            alignment: position,
            child: Icon(Icons.auto_awesome, color: AppColors.neonCyan.withValues(alpha: 0.35), size: 16),
          ),
      ],
    );
  }
}
