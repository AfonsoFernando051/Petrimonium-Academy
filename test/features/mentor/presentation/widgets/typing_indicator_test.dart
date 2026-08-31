import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/mentor/presentation/widgets/typing_indicator.dart';

void main() {
  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: TypingIndicator()),
    );
  }

  group('TypingIndicator', () {
    testWidgets('renders three pulsing dots left-aligned', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);

      // 3 dots + the outer AnimatedBuilder-driven containers.
      final containers = find.descendant(
        of: find.byType(TypingIndicator),
        matching: find.byWidgetPredicate((w) => w is Container && w.decoration is BoxDecoration && (w.decoration! as BoxDecoration).shape == BoxShape.circle),
      );
      expect(containers, findsNWidgets(3));
    });

    testWidgets('animates without throwing across several frames', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TypingIndicator), findsOneWidget);
    });

    testWidgets('honors disableAnimations — still renders its three dots, no crash', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestableWidget(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
      final containers = find.descendant(
        of: find.byType(TypingIndicator),
        matching: find.byWidgetPredicate((w) => w is Container && w.decoration is BoxDecoration && (w.decoration! as BoxDecoration).shape == BoxShape.circle),
      );
      expect(containers, findsNWidgets(3));
    });
  });
}
