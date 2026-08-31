import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/pet_configuration_screen.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildThemedTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const WelcomeScreen(),
    );
  }

  group('WelcomeScreen', () {
    // Reduced-motion mode is set for the whole group: each _FloatingIcon
    // and PetHeroCapsule reads `MediaQuery.disableAnimations` and skips its
    // one-shot Future.delayed / repeat() entirely when it's set (per their
    // own doc comments), which sidesteps a real timing hazard — the icons
    // only actually mount partway through OnboardingScaffold's internal
    // LayoutBuilder, so a delayed timer scheduled there is not reliably
    // flushable by elapsing a fixed pump duration and would otherwise trip
    // the framework's "pending Timer after dispose" check. GameButton's own
    // pulse animation still repeats regardless (it doesn't check reduced
    // motion) — that's a Ticker, not a Timer, so it's unaffected by this and
    // the usual "never call pumpAndSettle" rule still applies below.
    testWidgets('renders the headline, subheadline, body and CTA', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      await tester.pumpWidget(buildThemedTestableWidget());
      await tester.pump();

      expect(find.text('Sua jornada financeira começa aqui.'), findsOneWidget);
      expect(find.text('Aprenda. Invista. Evolua.'), findsOneWidget);
      expect(find.text('Transforme conhecimento financeiro em progresso de verdade.'), findsOneWidget);
      expect(find.text('Começar'), findsOneWidget);
    });

    testWidgets('shows a Skip action that also proceeds to PetConfigurationScreen', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      await tester.pumpWidget(buildThemedTestableWidget());
      await tester.pump();

      expect(find.text('Pular'), findsOneWidget);

      await tester.tap(find.text('Pular'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(PetConfigurationScreen), findsOneWidget);
    });

    testWidgets('tapping the CTA navigates to PetConfigurationScreen', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      await tester.pumpWidget(buildThemedTestableWidget());
      await tester.pump();

      await tester.tap(find.byType(GameButton), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(PetConfigurationScreen), findsOneWidget);
    });
  });
}
