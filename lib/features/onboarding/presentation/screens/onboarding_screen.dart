import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_form.dart';

/// The risk-tolerance questionnaire ("Guardian/Tactician/Adventurer" —
/// `docs/FEATURES.md`'s Pet System section) — conceptually distinct from the
/// 7-step first-run onboarding wizard's `FinancialGoalScreen`/
/// `TimeHorizonScreen` (a single motivational goal pick). Both used to read
/// as "the same onboarding step answered twice" because they shared similar
/// copy; the title/subtitle here now explicitly say this is about risk
/// tolerance, not the goal already answered elsewhere.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      backgroundColor: tokens.backgroundPrimary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Translator.translate(AppStrings.investorProfileScreenTitle),
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: tokens.surface.withValues(alpha: context.isDarkMode ? 0.06 : 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: tokens.border),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadow,
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Subtle watermark — single layer, low opacity
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.15,
                          child: Image.asset(
                            'assets/images/questionary_space_paw.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.topRight,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Translator.translate(AppStrings.investorProfileScreenSubtitle),
                              style: TextStyle(color: tokens.textSecondary, fontSize: 12.5, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            const OnboardingForm(),
                          ],
                        ),
                      ),
                      
                      // Bottom right star decoration - moved inside the card
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Icon(
                          Icons.auto_awesome,
                          color: tokens.textPrimary.withValues(alpha: 0.6),
                          size: 24,
                        ),
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
    );
  }
}

