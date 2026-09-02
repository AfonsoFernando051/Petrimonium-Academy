import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_companion_header.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';

/// Shared chrome for every Financial Lab screen (the Lab home and each
/// simulator) — AppBar with a back button and a Pet companion avatar,
/// `CosmicBackground`, a scrollable body, and the Pet's own anchored speech
/// bubble overlay. Byte-for-byte the same shape as `ProfileScreen`'s chrome
/// (own [PetSpeechBubbleAnchor], own `PetSpeechBubbleOverlay` mounted via
/// `Positioned.fill` inside a `Stack`) since Lab screens are pushed routes
/// exactly like Profile — `DashboardScreen`'s own overlay/anchor can't reach
/// them (see `docs/DECISIONS.md` DECISION-037).
class LabScaffold extends StatelessWidget {
  const LabScaffold({
    super.key,
    required this.titleKey,
    required this.children,
    required this.companionController,
    required this.anchor,
  });

  final String titleKey;
  final List<Widget> children;
  final PetCompanionController companionController;
  final PetSpeechBubbleAnchor anchor;

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
              anchor: anchor,
              onDestinationSelected: (destination) =>
                  Navigator.of(context).pop(destination),
            ),
            const SizedBox(width: 10),
            Text(
              Translator.translate(titleKey),
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              child: Column(
                children: [
                  const _SimulatedDataBadge(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.lg,
                        children: children,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: PetSpeechBubbleOverlay(
                controller: companionController,
                anchor: anchor,
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

/// Persistent "this is a simulation" mark, shown outside the scroll view so
/// it never scrolls away — every Financial Lab screen must carry it on
/// every screen per the design system's guardrail (simulated/fictional data
/// is never allowed to read as the user's real portfolio).
class _SimulatedDataBadge extends StatelessWidget {
  const _SimulatedDataBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 8, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.warningAmber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science_outlined, size: 14, color: AppColors.warningAmber),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                Translator.translate(AppStrings.labSimulatedDataBadge),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [PetContext.academy] is what every Financial Lab screen enters — there is
/// no dedicated `PetContext.lab` (see `pet_context.dart`'s doc comment on
/// why the enum mirrors the app's real top-level destinations only).
const PetContext labPetContext = PetContext.academy;
