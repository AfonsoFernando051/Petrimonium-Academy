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

  /// The selected goal row is the only one carrying a `check_circle` icon
  /// (conditionally built, not just faded) — so "is this goal selected" is
  /// asserted by whether that icon is present inside its row.
  bool isGoalSelected(WidgetTester tester, PetGoalEnum goal) {
    final rowFinder = find.ancestor(
      of: find.text(goal.label),
      matching: find.byType(InkWell),
    );
    return find.descendant(of: rowFinder, matching: find.byIcon(Icons.check_circle)).evaluate().isNotEmpty;
  }

  group('FinancialGoalScreen', () {
    testWidgets('renders the title, subtitle and a row for every goal', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Hosts CosmicBackground + a pulsing GameButton — never pumpAndSettle.
      await tester.pump();

      expect(find.text('Qual é o seu objetivo agora?'), findsOneWidget);
      expect(find.text('Isso ajusta sua trilha. Você pode mudar depois.'), findsOneWidget);
      for (final goal in PetGoalEnum.values) {
        expect(find.text(goal.label), findsOneWidget, reason: goal.name);
        expect(find.text(goal.emoji), findsOneWidget, reason: goal.name);
      }
    });

    testWidgets('defaults to investWithConfidence selected', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(isGoalSelected(tester, PetGoalEnum.investWithConfidence), isTrue);
      expect(isGoalSelected(tester, PetGoalEnum.justWantToLearn), isFalse);
    });

    testWidgets('tapping a goal row selects it', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final learnRow = find.text(PetGoalEnum.justWantToLearn.label);
      await tester.ensureVisible(learnRow);
      await tester.pump();
      await tester.tap(learnRow);
      await tester.pump(const Duration(milliseconds: 200));

      expect(isGoalSelected(tester, PetGoalEnum.justWantToLearn), isTrue);
      expect(isGoalSelected(tester, PetGoalEnum.investWithConfidence), isFalse);
    });

    testWidgets('tapping Continue saves the selected goal and navigates to TimeHorizonScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final debtRow = find.text(PetGoalEnum.getOutOfDebt.label);
      await tester.ensureVisible(debtRow);
      await tester.pump();
      await tester.tap(debtRow);
      await tester.pump(const Duration(milliseconds: 200));

      final continueButton = find.text('Continuar');
      await tester.ensureVisible(continueButton);
      await tester.pump();
      await tester.tap(continueButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(await DI.petPreferencesRepository.loadGoal(), PetGoalEnum.getOutOfDebt);
      expect(find.byType(TimeHorizonScreen), findsOneWidget);
    });
  });
}
