import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/settings/presentation/widgets/account_section.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({String? email, VoidCallback? onLogout}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AccountSection(
          sectionLabel: (label) => Text(label),
          email: email,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  group('AccountSection', () {
    testWidgets('renders the section label, the email and a logout button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(email: 'user@example.com'));

      expect(find.text('CONTA'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('omits the email row and divider when email is null', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(email: null));

      expect(find.byIcon(Icons.person_outline), findsNothing);
      expect(find.byType(Divider), findsNothing);
      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets('invokes onLogout when the logout button is tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(email: 'user@example.com', onLogout: () => tapped = true));

      await tester.tap(find.text('Sair'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
