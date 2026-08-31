import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/confirm_logout_dialog.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget(void Function(bool?) onResult) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await ConfirmLogoutDialog.show(context);
              onResult(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  group('ConfirmLogoutDialog', () {
    testWidgets('shows the title and message', (tester) async {
      await tester.pumpWidget(buildTestableWidget((_) {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Sair'), findsWidgets);
    });

    testWidgets('tapping cancel resolves to false and dismisses the dialog', (tester) async {
      bool? result;
      await tester.pumpWidget(buildTestableWidget((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping logout resolves to true and dismisses the dialog', (tester) async {
      bool? result;
      await tester.pumpWidget(buildTestableWidget((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair').last);
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
