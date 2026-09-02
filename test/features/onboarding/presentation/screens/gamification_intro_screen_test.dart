import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/gamification_intro_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const GamificationIntroScreen(),
    );
  }

  group('GamificationIntroScreen', () {
    testWidgets('renders the title and the three progression rules', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Hosts CosmicBackground and a pulsing GameButton — repeating
      // AnimationControllers, so never call pumpAndSettle.
      await tester.pump();

      expect(find.text('Como você progride aqui'), findsOneWidget);

      expect(find.text('XP por aprender'), findsOneWidget);
      expect(
        find.text('Você ganha XP completando aulas e práticas — nunca por valorização, aporte ou operação.'),
        findsOneWidget,
      );

      expect(find.text('Ofensiva sem punição'), findsOneWidget);
      expect(
        find.text('Perder um dia não zera seu progresso nem te penaliza — o pet só fica com saudade.'),
        findsOneWidget,
      );

      expect(find.text('Sem comparação entre pessoas'), findsOneWidget);
      expect(
        find.text('Seu progresso é só seu. Não existe ranking de patrimônio ou retorno aqui.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Next navigates to FinancialGoalScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.tap(find.text('Próximo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(FinancialGoalScreen), findsOneWidget);
    });

    testWidgets('tapping Skip also navigates to FinancialGoalScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.tap(find.text('Pular'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(FinancialGoalScreen), findsOneWidget);
    });
  });
}
