import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

/// Shared chrome for every screen in the onboarding narrative arc (Welcome
/// through Journey Ready): the cosmic background at a screen-appropriate
/// [intensity], an optional top-right Skip, a centered title/subtitle block,
/// a scrollable [body], and a bottom bar with [OnboardingProgressDots] plus
/// the primary CTA. Centralizing this means every screen gets identical
/// safe-area handling, tablet/desktop width clamping, vertical centering
/// (short content is centered rather than hugging the top — an empty-feeling
/// screen was one of the redesign's explicit complaints about the old
/// onboarding) and CTA placement instead of each screen reinventing its own
/// `LayoutBuilder`.
///
/// [body] must be a plain `Column` with `mainAxisSize: MainAxisSize.min` —
/// it must not wrap itself in another scrollable, and must not use
/// `Expanded`/`Flexible` children, since the scaffold already makes the
/// whole body area scrollable-and-centered (an unbounded scroll axis).
///
/// `PortfolioChoiceScreen` deliberately does NOT use this scaffold — it's an
/// epilogue reachable from Home too, not part of the numbered narrative arc.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.intensity,
    required this.step,
    required this.totalSteps,
    this.title,
    this.subtitle,
    required this.body,
    required this.ctaLabel,
    required this.onCta,
    this.isCtaLoading = false,
    this.showSkip = false,
    this.onSkip,
    this.maxContentWidth = 560,
  });

  final BackgroundIntensity intensity;
  final int step;
  final int totalSteps;

  /// Null for a hero-style screen (e.g. Welcome) that composes its own
  /// badge/mascot/headline order directly inside [body] instead of using
  /// this dedicated slot — skips the title block entirely rather than
  /// rendering an empty one.
  final String? title;
  final String? subtitle;
  final Widget body;
  final String ctaLabel;
  final VoidCallback? onCta;
  final bool isCtaLoading;
  final bool showSkip;
  final VoidCallback? onSkip;

  /// Widens the content/CTA column beyond the default 560 — used by screens
  /// with a wide grid (Goal, Time Horizon) so a 2-column/3-across layout has
  /// room to breathe on tablet/desktop.
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      body: CosmicBackground(
        intensity: intensity,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: showSkip
                    ? Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextButton(
                            onPressed: onSkip,
                            child: Text(
                              Translator.translate(AppStrings.onboardingSkip),
                              style: TextStyle(color: tokens.textSecondary),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (title != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Text(
                                  title!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: tokens.textPrimary,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    subtitle!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: tokens.textSecondary,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Centers short content vertically within the
                              // available space (rather than hugging the
                              // top, which reads as an empty screen) while
                              // still scrolling normally if [body] overflows
                              // on a small viewport. [body] must be a Column
                              // with `mainAxisSize: MainAxisSize.min` — it
                              // must NOT wrap itself in another scroll view
                              // or use Expanded/Flexible children, since the
                              // scroll axis here is unbounded.
                              return SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: body,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      OnboardingProgressDots(step: step, total: totalSteps),
                      const SizedBox(height: 16),
                      GameButton(
                        label: ctaLabel,
                        icon: Icons.arrow_forward,
                        iconTrailing: true,
                        pulse: true,
                        isLoading: isCtaLoading,
                        onPressed: onCta,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
