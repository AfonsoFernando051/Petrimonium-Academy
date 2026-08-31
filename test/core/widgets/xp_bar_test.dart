import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/xp_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('XpBar', () {
    testWidgets('renders without a label when none is provided', (tester) async {
      await tester.pumpWidget(wrap(const XpBar(progress: 0.5)));

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders the label text when provided', (tester) async {
      await tester.pumpWidget(wrap(const XpBar(progress: 0.5, label: '50 / 100 XP')));

      expect(find.text('50 / 100 XP'), findsOneWidget);
    });

    testWidgets('clamps a progress value above 1.0', (tester) async {
      await tester.pumpWidget(wrap(const XpBar(progress: 1.5)));

      final fractional = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(fractional.widthFactor, 1.0);
    });

    testWidgets('clamps a negative progress value to 0.0', (tester) async {
      await tester.pumpWidget(wrap(const XpBar(progress: -0.3)));

      final fractional = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(fractional.widthFactor, 0.0);
    });

    testWidgets('honors a custom height for the track', (tester) async {
      await tester.pumpWidget(wrap(const XpBar(progress: 0.5, height: 20)));

      final track = tester.widgetList<Container>(find.byType(Container)).first;
      expect(track.constraints?.maxHeight, 20);
    });
  });
}
