import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/pet_hero_capsule.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/pet_configuration_screen.dart';

/// Onboarding's opening beat — a real emotional entrance rather than a form.
/// No species/name is chosen yet (that's `PetConfigurationScreen`, the next
/// screen), so the pet is shown generically via `PetAssets.imageFor(null)`
/// (safe default portrait) as "the adventure about to begin", not as the
/// player's actual companion yet.
///
/// Composes its own badge → mascot → headline → subtitle order directly in
/// [OnboardingScaffold.body] (leaving its dedicated title slot unused) to
/// match the Notion mockup's hero layout — every other onboarding screen
/// uses the scaffold's title-above-body order instead, which is why this is
/// the one screen that opts out of it.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goNext(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PetConfigurationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      intensity: BackgroundIntensity.balanced,
      step: 1,
      totalSteps: 7,
      showSkip: true,
      onSkip: () => _goNext(context),
      ctaLabel: Translator.translate(AppStrings.welcomeCta),
      onCta: () => _goNext(context),
      body: Builder(
        builder: (context) {
          final tokens = context.colors;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Translator.translate(AppStrings.welcomeSubheadline),
                style: TextStyle(
                  color: tokens.mentor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              PetHeroCapsule(
                size: 180,
                child: Image.asset(PetAssets.imageFor(null), fit: BoxFit.contain),
              ),
              const SizedBox(height: 24),
              Text(
                Translator.translate(AppStrings.welcomeHeadline),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Translator.translate(AppStrings.welcomeBody),
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, fontSize: 14, height: 1.4),
              ),
            ],
          );
        },
      ),
    );
  }
}
