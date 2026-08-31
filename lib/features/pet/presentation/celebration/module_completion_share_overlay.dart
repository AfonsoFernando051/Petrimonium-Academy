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

/// The one-time social-sharing celebration for finishing an Academy module.
/// It reuses the existing progress card so posts remain visually consistent
/// and always represent learning progress rather than financial performance.
class ModuleCompletionShareOverlay extends StatefulWidget {
  const ModuleCompletionShareOverlay({
    super.key,
    required this.moduleTitle,
    required this.mascotController,
    required this.onDismiss,
  });

  final String moduleTitle;
  final MascotController mascotController;
  final VoidCallback onDismiss;

  @override
  State<ModuleCompletionShareOverlay> createState() =>
      _ModuleCompletionShareOverlayState();
}

class _ModuleCompletionShareOverlayState
    extends State<ModuleCompletionShareOverlay> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

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
        fileName: 'invest_game_module.png',
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
          SnackBar(
            content: Text(
              Translator.translate(AppStrings.shareProgressErrorMessage),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final playerLevel = LevelCalculator.fromXp(
      widget.mascotController.profile.xp,
    );
    final petImagePath = PetAssets.imageFor(
      widget.mascotController.profile.specie.name,
    );

    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: tokens.overlay,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: () {},
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: AppColors.goldenBorder,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        Translator.translate(
                          AppStrings.academyModuleShareTitle,
                        ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.moduleTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.subtleText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RepaintBoundary(
                        key: _cardKey,
                        child: LevelUpShareCard(
                          petImagePath: petImagePath,
                          playerLevel: playerLevel,
                          totalXp: widget.mascotController.profile.xp,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _dismiss,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.subtleText,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                ),
                              ),
                              child: Text(
                                Translator.translate(
                                  AppStrings.shareProgressContinueButton,
                                ),
                                style: AppTextStyles.bodyEmphasis.copyWith(
                                  color: Colors.white,
                                ),
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.ios_share, size: 18),
                              label: Text(
                                Translator.translate(
                                  AppStrings.shareProgressButton,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldenBorder,
                                foregroundColor: AppColors.spaceDark,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                ),
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
    );
  }
}
