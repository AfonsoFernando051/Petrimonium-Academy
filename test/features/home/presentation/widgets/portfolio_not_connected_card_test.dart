import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_not_connected_card.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({bool showInvestorProfileAction = false}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PortfolioNotConnectedCard(showInvestorProfileAction: showInvestorProfileAction),
      ),
    );
  }

  group('PortfolioNotConnectedCard', () {
    testWidgets('renders the title, body and connect CTA', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // GameButton uses no pulse here, but hosts a repeating pulse only
      // when pulse:true is passed — it's not here, so a single pump
      // suffices; kept for consistency with the rest of this batch anyway.
      await tester.pump();

      expect(find.text('Portfólio ainda não conectado'), findsOneWidget);
      expect(find.text('Conecte seus investimentos quando estiver pronto — sem pressa.'), findsOneWidget);
      expect(find.text('Conectar Investimentos'), findsOneWidget);
    });

    testWidgets('omits the investor-profile link by default', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Ainda não respondeu seu perfil de risco? Responder agora'), findsNothing);
    });

    testWidgets('shows the investor-profile link when showInvestorProfileAction is true', (tester) async {
      await tester.pumpWidget(buildTestableWidget(showInvestorProfileAction: true));
      await tester.pump();

      expect(find.text('Ainda não respondeu seu perfil de risco? Responder agora'), findsOneWidget);
    });

    testWidgets('tapping the connect CTA navigates to PortfolioChoiceScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.tap(find.byType(GameButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(PortfolioChoiceScreen), findsOneWidget);
    });

    testWidgets('tapping the investor-profile link navigates to OnboardingScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget(showInvestorProfileAction: true));
      await tester.pump();

      await tester.tap(find.text('Ainda não respondeu seu perfil de risco? Responder agora'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}
