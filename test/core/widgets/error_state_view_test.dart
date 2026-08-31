import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/error_state_view.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({
    String? title,
    required String message,
    required Future<void> Function() onRetry,
    ErrorStateStyle style = ErrorStateStyle.standard,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: ErrorStateView(title: title, message: message, onRetry: onRetry, style: style),
      ),
    );
  }

  group('ErrorStateView', () {
    testWidgets('standard style renders title and message', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        title: 'Oops',
        message: 'Something went wrong',
        onRetry: () async {},
      ));

      expect(find.text('Oops'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('standard style with no title omits it', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        message: 'Something went wrong',
        onRetry: () async {},
      ));

      expect(find.text('Something went wrong'), findsOneWidget);
      // Only the message + retry Text widgets should exist as titleLarge-style.
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('card style wraps content in a GlassCard', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        message: 'Card error',
        onRetry: () async {},
        style: ErrorStateStyle.card,
      ));

      expect(find.byType(GlassCard), findsOneWidget);
      expect(find.text('Card error'), findsOneWidget);
    });

    testWidgets('compact style renders a text-only retry action, no title support', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        title: 'Ignored',
        message: 'Compact error',
        onRetry: () async {},
        style: ErrorStateStyle.compact,
      ));

      expect(find.text('Ignored'), findsNothing);
      expect(find.text('Compact error'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('tapping retry invokes onRetry — standard style', (tester) async {
      var called = false;
      await tester.pumpWidget(buildTestableWidget(
        message: 'msg',
        onRetry: () async {
          called = true;
        },
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('tapping retry invokes onRetry — compact style', (tester) async {
      var called = false;
      await tester.pumpWidget(buildTestableWidget(
        message: 'msg',
        onRetry: () async {
          called = true;
        },
        style: ErrorStateStyle.compact,
      ));

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });
  });
}
