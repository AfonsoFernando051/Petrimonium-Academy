import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/fade_route.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/unavailable_badge.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_companion_header.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/settings/presentation/screens/settings_screen.dart';

/// The "Perfil" experience — previously its own bottom-nav tab, now reached
/// via the AppBar's config/gear icon instead (the Perfil tab was removed;
/// the gear icon is now responsible for everything it used to cover).
///
/// Keeps the same [PetCompanionController] instance `DashboardScreen` owns
/// (not a new one) so the companion's message/cooldown state stays
/// continuous across the push — see that controller's class doc.
class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key, required this.companionController});

  final PetCompanionController companionController;

  // This screen's own Pet anchor (a fresh `LayerLink`/`GlobalKey` pair, not
  // shared with `DashboardScreen`'s — Profile is pushed on top of it, so
  // both remain mounted simultaneously and a shared `GlobalKey` would
  // collide). See `PetSpeechBubbleAnchor`'s doc comment.
  final PetSpeechBubbleAnchor _headerAnchor = PetSpeechBubbleAnchor();

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PetCompanionHeader(
              controller: companionController,
              onDestinationSelected: (destination) =>
                  Navigator.of(context).pop(destination),
              anchor: _headerAnchor,
            ),
            const SizedBox(width: 10),
            Text(Translator.translate(AppStrings.profileTitle), style: TextStyle(color: tokens.textPrimary)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: CosmicBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: GlassCard(
                  backgroundColor: tokens.surface.withValues(
                    alpha: context.isDarkMode ? 0.6 : 0.94,
                  ),
                  borderColor: AppColors.neonPink.withValues(alpha: 0.3),
                  borderRadius: 24,
                  borderWidth: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.manage_accounts,
                          size: 64,
                          color: AppColors.neonPink.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          Translator.translate(AppStrings.profileCommanderTitle),
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Translator.translate(AppStrings.profileAchievementsLabel),
                              style: TextStyle(
                                color: tokens.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const UnavailableBadge(),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          Translator.translate(AppStrings.profileAchievementsComingSoonBody),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Translator.translate(AppStrings.profileSettingsHint),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tokens.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: AppColors.neonPink,
                          ),
                          label: const Text(
                            'Configurações',
                            style: TextStyle(
                              color: AppColors.neonPink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.neonPink),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(
                              context,
                            ).push(fadeRoute(const SettingsScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: PetSpeechBubbleOverlay(
                controller: companionController,
                anchor: _headerAnchor,
                onActionSelected: (action) =>
                    Navigator.of(context).pop(action.destination),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
