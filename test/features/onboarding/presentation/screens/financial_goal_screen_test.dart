import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_preferences_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/time_horizon_screen.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});
    DI.petPreferencesRepository = PetPreferencesRepository();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const FinancialGoalScreen(),
    );
  }

  /// The check mark on each goal card is always present in the tree — its
  /// visibility is driven by an `AnimatedOpacity` (opacity 0/1), not
  /// conditional rendering — so "is this goal selected" is asserted via
  /// that opacity rather than a raw icon-presence count.
  bool isGoalSelected(WidgetTester tester, PetGoalEnum goal) {
    // Locate the card (the InkWell ancestor of its label) and check its
    // one AnimatedOpacity — the check mark is always present in the tree,
    // just faded out (opacity 0) when not selected.
    final cardFinder = find.ancestor(
      of: find.text(goal.label),
      matching: find.byType(InkWell),
    );
    final opacity = tester.widget<AnimatedOpacity>(
      find.descendant(of: cardFinder, matching: find.byType(AnimatedOpacity)).first,
    );
    return opacity.opacity == 1.0;
  }

  group('FinancialGoalScreen', () {
    testWidgets('renders the title, subtitle and a card for every goal', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Hosts CosmicBackground + a pulsing GameButton — never pumpAndSettle.
      await tester.pump();

      expect(find.text('Qual será sua primeira missão?'), findsOneWidget);
      expect(
        find.text('Escolha o que você quer alcançar. Você pode mudar isso depois.'),
        findsOneWidget,
      );
      for (final goal in PetGoalEnum.values) {
        expect(find.text(goal.label), findsOneWidget, reason: goal.name);
      }
    });

    testWidgets('defaults to buildWealth selected', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(isGoalSelected(tester, PetGoalEnum.buildWealth), isTrue);
      expect(isGoalSelected(tester, PetGoalEnum.travel), isFalse);
    });

    testWidgets('tapping a goal card selects it', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final travelCard = find.text(PetGoalEnum.travel.label);
      await tester.ensureVisible(travelCard);
      await tester.pump();
      await tester.tap(travelCard);
      await tester.pump(const Duration(milliseconds: 200));

      expect(isGoalSelected(tester, PetGoalEnum.travel), isTrue);
      expect(isGoalSelected(tester, PetGoalEnum.buildWealth), isFalse);
    });

    testWidgets('tapping Continue saves the selected goal and navigates to TimeHorizonScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final retireCard = find.text(PetGoalEnum.retireEarly.label);
      await tester.ensureVisible(retireCard);
      await tester.pump();
      await tester.tap(retireCard);
      await tester.pump(const Duration(milliseconds: 200));

      final continueButton = find.text('Continuar');
      await tester.ensureVisible(continueButton);
      await tester.pump();
      await tester.tap(continueButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(await DI.petPreferencesRepository.loadGoal(), PetGoalEnum.retireEarly);
      expect(find.byType(TimeHorizonScreen), findsOneWidget);
    });
  });
}
