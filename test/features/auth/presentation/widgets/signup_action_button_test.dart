import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_action_button.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({VoidCallback? onPressed, bool isLoading = false}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: SignupActionButton(onPressed: onPressed, isLoading: isLoading),
      ),
    );
  }

  group('SignupActionButton', () {
    testWidgets('renders the translated label', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.byType(GameButton), findsOneWidget);
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(onPressed: () => tapped = true));

      await tester.tap(find.byType(GameButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('passes isLoading through to the GameButton', (tester) async {
      await tester.pumpWidget(buildTestableWidget(isLoading: true));

      final gameButton = tester.widget<GameButton>(find.byType(GameButton));
      expect(gameButton.isLoading, isTrue);
    });
  });
}
