import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/settings/presentation/widgets/appearance_option_card.dart';

void main() {
  Widget buildTestableWidget({
    required bool selected,
    required VoidCallback onTap,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AppearanceOptionCard(
          icon: Icons.light_mode_rounded,
          label: 'Light',
          description: 'Bright and clean',
          swatchColors: const [Color(0xFFFFD97A), Color(0xFF00B4C6)],
          selected: selected,
          onTap: onTap,
        ),
      ),
    );
  }

  group('AppearanceOptionCard', () {
    testWidgets('renders icon, label and description', (tester) async {
      await tester.pumpWidget(buildTestableWidget(selected: false, onTap: () {}));

      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Bright and clean'), findsOneWidget);
    });

    testWidgets('shows a filled check icon when selected', (tester) async {
      await tester.pumpWidget(buildTestableWidget(selected: true, onTap: () {}));

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNothing);
    });

    testWidgets('shows an outlined circle icon when not selected', (tester) async {
      await tester.pumpWidget(buildTestableWidget(selected: false, onTap: () {}));

      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('invokes onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(selected: false, onTap: () => tapped = true));

      await tester.tap(find.byType(AppearanceOptionCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
