import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_reminder_banner.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({VoidCallback? onDismiss}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PortfolioReminderBanner(onDismiss: onDismiss ?? () {}),
      ),
    );
  }

  group('PortfolioReminderBanner', () {
    testWidgets('renders the reminder message and both actions', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(
        find.textContaining('Percebi que ainda não conectamos seus investimentos'),
        findsOneWidget,
      );
      expect(find.text('Agora não'), findsOneWidget);
      expect(find.text('Conectar agora'), findsOneWidget);
    });

    testWidgets('tapping "Agora não" invokes onDismiss only', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildTestableWidget(onDismiss: () => dismissed = true));

      await tester.tap(find.text('Agora não'));
      await tester.pump();

      expect(dismissed, isTrue);
      expect(find.byType(PortfolioChoiceScreen), findsNothing);
    });

    testWidgets('tapping "Conectar agora" dismisses and navigates to PortfolioChoiceScreen', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildTestableWidget(onDismiss: () => dismissed = true));

      await tester.tap(find.text('Conectar agora'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(dismissed, isTrue);
      expect(find.byType(PortfolioChoiceScreen), findsOneWidget);
    });
  });
}
