import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

void main() {
  Widget buildTestableWidget({
    String? subtitle,
    bool showSkip = false,
    VoidCallback? onSkip,
    VoidCallback? onCta,
    bool isCtaLoading = false,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: OnboardingScaffold(
        step: 2,
        totalSteps: 5,
        title: 'Título de teste',
        subtitle: subtitle,
        body: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Conteúdo do corpo')],
        ),
        ctaLabel: 'Continuar',
        onCta: onCta,
        isCtaLoading: isCtaLoading,
        showSkip: showSkip,
        onSkip: onSkip,
      ),
    );
  }

  group('OnboardingScaffold', () {
    testWidgets('renders title, subtitle, body and CTA', (tester) async {
      await tester.pumpWidget(buildTestableWidget(subtitle: 'Subtítulo'));
      // Hosts CosmicBackground and a pulsing GameButton — both use
      // repeating AnimationControllers, so never call pumpAndSettle.
      await tester.pump();

      expect(find.text('Título de teste'), findsOneWidget);
      expect(find.text('Subtítulo'), findsOneWidget);
      expect(find.text('Conteúdo do corpo'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.byType(OnboardingProgressBar), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);
    });

    testWidgets('omits the subtitle block when null', (tester) async {
      await tester.pumpWidget(buildTestableWidget(subtitle: null));
      await tester.pump();

      expect(find.text('Subtítulo'), findsNothing);
    });

    testWidgets('shows the Skip action only when showSkip is true', (tester) async {
      await tester.pumpWidget(buildTestableWidget(showSkip: false));
      await tester.pump();
      expect(find.text('Pular'), findsNothing);

      await tester.pumpWidget(buildTestableWidget(showSkip: true, onSkip: () {}));
      await tester.pump();
      expect(find.text('Pular'), findsOneWidget);
    });

    testWidgets('tapping Skip invokes onSkip', (tester) async {
      var skipped = false;
      await tester.pumpWidget(buildTestableWidget(showSkip: true, onSkip: () => skipped = true));
      await tester.pump();

      await tester.tap(find.text('Pular'));
      await tester.pump();

      expect(skipped, isTrue);
    });

    testWidgets('tapping the CTA invokes onCta', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(onCta: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(GameButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows a loading GameButton when isCtaLoading is true', (tester) async {
      await tester.pumpWidget(buildTestableWidget(onCta: () {}, isCtaLoading: true));
      await tester.pump();

      final button = tester.widget<GameButton>(find.byType(GameButton));
      expect(button.isLoading, isTrue);
    });
  });
}
