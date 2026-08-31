import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/utils/widget_image_capture.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/pet/presentation/celebration/level_up_share_card.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:share_plus/share_plus.dart';

/// The reward moment shown the instant `UserLeveledUpEvent` fires (see
/// `DashboardScreen._onAppEvent`) — replaces the old plain `GameSnack`
/// toast with a real celebration that doubles as a social-share prompt
/// (brief: "share progress like a level-up to post on Instagram").
///
/// Mirrors `AchievementCelebrationOverlay`'s structure/animation, but wraps
/// its captureable content (`LevelUpShareCard`) in a `RepaintBoundary` so
/// the exact card the user sees is also the exact image that gets shared.
class LevelUpCelebrationOverlay extends StatefulWidget {
  const LevelUpCelebrationOverlay({
    super.key,
    required this.newLevel,
    required this.mascotController,
    required this.onDismiss,
  });

  final int newLevel;
  final MascotController mascotController;
  final VoidCallback onDismiss;

  @override
  State<LevelUpCelebrationOverlay> createState() => _LevelUpCelebrationOverlayState();
}

class _LevelUpCelebrationOverlayState extends State<LevelUpCelebrationOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.4, curve: Curves.easeOut),
  );

  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (mounted) widget.onDismiss();
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    HapticFeedback.selectionClick();
    try {
      final file = await WidgetImageCapture.captureToFile(
        _cardKey,
        fileName: 'invest_game_level_${widget.newLevel}.png',
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: Translator.translate(AppStrings.shareProgressTagline),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Translator.translate(AppStrings.shareProgressErrorMessage))),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final playerLevel = LevelCalculator.fromXp(widget.mascotController.profile.xp);
    final petImagePath = PetAssets.imageFor(widget.mascotController.profile.specie.name);

    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: tokens.overlay,
        // Scrollable rather than a plain `Center` — the share card's 4:5
        // portrait shape plus title/buttons can exceed a short device's
        // viewport (small phones, landscape), and a `RenderFlex` overflow
        // there would silently clip the share buttons off-screen.
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: GestureDetector(
                    onTap: () {}, // absorb taps so the card itself doesn't dismiss-through
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SparkleBurst(controller: _controller),
                          const SizedBox(height: 4),
                          Text(
                            Translator.translate(AppStrings.levelUpAchieved, params: {'level': '${widget.newLevel}'}),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headline.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          RepaintBoundary(
                            key: _cardKey,
                            child: LevelUpShareCard(
                              petImagePath: petImagePath,
                              playerLevel: playerLevel,
                              totalXp: widget.mascotController.profile.xp,
                              isLevelUp: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _dismiss,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.subtleText),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
                                  ),
                                  child: Text(
                                    Translator.translate(AppStrings.shareProgressContinueButton),
                                    style: AppTextStyles.bodyEmphasis.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _sharing ? null : _share,
                                  icon: _sharing
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.ios_share, size: 18),
                                  label: Text(Translator.translate(AppStrings.shareProgressButton)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.goldenBorder,
                                    foregroundColor: AppColors.spaceDark,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Same radiating-sparkle-icons treatment as
/// `AchievementCelebrationOverlay`'s `_SparkleBurst`, kept private per-file
/// (both are small enough that a shared widget would cost more in import
/// indirection than it'd save).
class _SparkleBurst extends StatelessWidget {
  const _SparkleBurst({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 6; i++) _sparkle(i),
              const Icon(Icons.military_tech, color: AppColors.goldenBorder, size: 44),
            ],
          );
        },
      ),
    );
  }

  Widget _sparkle(int index) {
    final angle = (index / 6) * 2 * pi;
    final distance = 34 * controller.value;
    final opacity = (1 - controller.value).clamp(0.0, 1.0);
    return Transform.translate(
      offset: Offset(cos(angle) * distance, sin(angle) * distance),
      child: Opacity(
        opacity: opacity,
        child: const Icon(Icons.auto_awesome, color: AppColors.neonCyan, size: 14),
      ),
    );
  }
}
