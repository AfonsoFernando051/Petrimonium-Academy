import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/game_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('GameButton (label constructor)', () {
    testWidgets('renders the label text', (tester) async {
      await tester.pumpWidget(wrap(GameButton(label: 'Continue', onPressed: () {})));

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('renders a leading icon by default', (tester) async {
      await tester.pumpWidget(wrap(GameButton(label: 'Go', icon: Icons.check, onPressed: () {})));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping invokes onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(GameButton(label: 'Tap me', onPressed: () => tapped = true)));

      await tester.tap(find.byType(GameButton));
      await tester.pump(const Duration(milliseconds: 150));

      expect(tapped, isTrue);
    });

    testWidgets('a null onPressed disables tapping', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(GameButton(
        label: 'Disabled',
        onPressed: null,
        // capture attempted tap via a wrapping GestureDetector isn't needed —
        // GameButton's InkWell.onTap itself becomes null when disabled.
      )));
      // ignore: unused_local_variable
      tapped = tapped;

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('isLoading shows a spinner instead of the label', (tester) async {
      await tester.pumpWidget(wrap(GameButton(label: 'Loading', isLoading: true, onPressed: () {})));

      expect(find.text('Loading'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('isLoading disables tapping', (tester) async {
      await tester.pumpWidget(wrap(GameButton(label: 'Loading', isLoading: true, onPressed: () {})));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });
  });

  group('GameButton.custom', () {
    testWidgets('renders the provided child content', (tester) async {
      await tester.pumpWidget(wrap(GameButton.custom(
        onPressed: () {},
        child: const Text('Custom content'),
      )));

      expect(find.text('Custom content'), findsOneWidget);
    });

    testWidgets('tapping invokes onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(GameButton.custom(
        onPressed: () => tapped = true,
        child: const Text('Custom'),
      )));

      await tester.tap(find.byType(GameButton));
      await tester.pump(const Duration(milliseconds: 150));

      expect(tapped, isTrue);
    });
  });
}
