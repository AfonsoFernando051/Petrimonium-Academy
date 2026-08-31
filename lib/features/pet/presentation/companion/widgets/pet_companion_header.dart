import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/rive/pet_rive_companion.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_interaction_sheet.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';

/// The compact, always-visible companion avatar shown in every major
/// screen's chrome (see `docs/PRODUCT_VISION.md`'s Pet Companion section).
/// Deliberately small — a portrait + a subtle "speaking" ring, never a full
/// scene — the pet's expressive, animated moment is `LearningHeroCard` on
/// Home; this is the thread that keeps it present everywhere else.
///
/// Tapping opens [PetInteractionSheet]. Rendering the speech bubble itself
/// is the host screen's job (`PetSpeechBubbleOverlay`) since it needs to
/// float above page content, not just below the avatar.
class PetCompanionHeader extends StatelessWidget {
  const PetCompanionHeader({
    super.key,
    required this.controller,
    this.onDestinationSelected,
    this.size,
    this.anchor,
  });

  final PetCompanionController controller;

  /// Reported when the user picks an option in [PetInteractionSheet] — the
  /// host screen decides what "go there" means (switch tab, push a route).
  final ValueChanged<PetContext>? onDestinationSelected;

  /// Explicit override for the avatar diameter. Defaults to a
  /// screen-width-based size within the 36-64px range the product spec
  /// calls for (mobile/tablet/desktop breakpoints collapse to one formula
  /// here since this app only ships to phones/tablets today).
  final double? size;

  /// When provided, registers this avatar as the Pet's on-screen position
  /// for `PetSpeechBubbleOverlay` to glue its bubble to (see
  /// [PetSpeechBubbleAnchor]'s doc comment). Omit on hosts that don't also
  /// render the speech bubble (there should never be more than one).
  final PetSpeechBubbleAnchor? anchor;

  double _resolveSize(BuildContext context) {
    if (size != null) return size!;
    final width = MediaQuery.of(context).size.shortestSide;
    if (width >= 900) return 56; // desktop/large-tablet
    if (width >= 600) return 48; // tablet
    return 40; // phone
  }

  Widget _wrapWithAnchor(Widget child) {
    final anchor = this.anchor;
    if (anchor == null) return child;
    return CompositedTransformTarget(
      link: anchor.link,
      child: KeyedSubtree(key: anchor.boxKey, child: child),
    );
  }

  Future<void> _openInteraction(BuildContext context) async {
    HapticFeedback.selectionClick();
    controller.openInteraction();
    final destination = await showModalBottomSheet<PetContext>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PetInteractionSheet(controller: controller),
    );
    controller.closeInteraction();
    if (destination != null) onDestinationSelected?.call(destination);
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = _resolveSize(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final speaking = controller.isSpeaking;
        return Semantics(
          button: true,
          label: Translator.translate(AppStrings.companionHeaderTooltip),
          child: Tooltip(
            message: Translator.translate(AppStrings.companionHeaderTooltip),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openInteraction(context),
                child: _wrapWithAnchor(
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: avatarSize,
                    height: avatarSize,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: speaking
                            ? AppColors.neonCyan
                            : AppColors.neonCyan.withValues(alpha: 0.6),
                        width: speaking ? 2 : 1.5,
                      ),
                      color: context.colors.surface.withValues(
                        alpha: context.isDarkMode ? 0.6 : 0.9,
                      ),
                      boxShadow: speaking
                          ? [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.45),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipOval(
                      child: PetRiveCompanion(
                        controller: controller.mascotController,
                        size: avatarSize - 4,
                        interactive: false,
                        interacting: controller.isInteractionOpen,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
