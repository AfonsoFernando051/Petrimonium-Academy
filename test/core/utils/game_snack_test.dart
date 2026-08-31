import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/game_snack.dart';

void main() {
  Widget buildTestable(void Function(BuildContext context) onPressed) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => onPressed(context),
              child: const Text('trigger'),
            );
          },
        ),
      ),
    );
  }

  group('GameSnack.show', () {
    testWidgets('shows a SnackBar with the given message', (tester) async {
      await tester.pumpWidget(buildTestable((context) => GameSnack.show(context, 'Hello there')));

      await tester.tap(find.text('trigger'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Hello there'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('isError shows the error icon', (tester) async {
      await tester.pumpWidget(buildTestable((context) => GameSnack.show(context, 'Oops', isError: true)));

      await tester.tap(find.text('trigger'));
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('isSuccess shows the success icon', (tester) async {
      await tester.pumpWidget(buildTestable((context) => GameSnack.show(context, 'Done', isSuccess: true)));

      await tester.tap(find.text('trigger'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });

  group('GameSnack.showWithHaptic', () {
    testWidgets('also shows a SnackBar (haptic call is a no-op in tests)', (tester) async {
      await tester.pumpWidget(buildTestable((context) => GameSnack.showWithHaptic(context, 'Haptic message')));

      await tester.tap(find.text('trigger'));
      await tester.pump();

      expect(find.text('Haptic message'), findsOneWidget);
    });
  });
}
