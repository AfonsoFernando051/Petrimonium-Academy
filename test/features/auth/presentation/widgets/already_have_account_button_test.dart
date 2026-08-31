import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/presentation/widgets/already_have_account_button.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: AlreadyHaveAccountButton(),
            ),
          ),
        ),
      ),
    );
  }

  group('AlreadyHaveAccountButton', () {
    testWidgets('renders the translated label', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Já tem conta? Entrar'), findsOneWidget);
    });

    testWidgets('pops the navigator when tapped', (tester) async {
      final observer = TestNavigatorObserver();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          navigatorObservers: [observer],
          home: const Scaffold(
            body: AlreadyHaveAccountButton(),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(observer.popped, isTrue);
    });
  });
}

class TestNavigatorObserver extends NavigatorObserver {
  bool popped = false;

  @override
  void didPop(Route route, Route? previousRoute) {
    popped = true;
  }
}
