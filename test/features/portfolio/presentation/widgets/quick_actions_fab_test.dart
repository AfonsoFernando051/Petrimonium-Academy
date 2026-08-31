import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/quick_actions_fab.dart';

void main() {
  Widget buildTestableWidget({
    required VoidCallback onBuy,
    required VoidCallback onSell,
    required VoidCallback onRebalance,
    required VoidCallback onReports,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              right: 4,
              bottom: 8,
              child: QuickActionsFab(
                onBuy: onBuy,
                onSell: onSell,
                onRebalance: onRebalance,
                onReports: onReports,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The main FAB always has this hero tag (see QuickActionsFab); each
  // sub-action's small FAB is tagged 'portfolio_action_<label>'.
  final mainFab = find.byWidgetPredicate(
    (w) => w is FloatingActionButton && w.heroTag == 'portfolio_quick_actions',
  );
  Finder subActionFab(String label) => find.byWidgetPredicate(
        (w) => w is FloatingActionButton && w.heroTag == 'portfolio_action_$label',
      );
  Finder ignorePointersInFab() => find.descendant(
        of: find.byType(QuickActionsFab),
        matching: find.byType(IgnorePointer),
      );
  // Sell/Reports are `available: false` (Product Trust pass — no false
  // affordance) and stay hit-test-ignored even while the speed dial is
  // open; only the two implemented actions (Investir/Ver Alocação) toggle
  // with `_open`. So assertions below must check the specific action's
  // IgnorePointer ancestor, not "every IgnorePointer in the widget".
  IgnorePointer ignorePointerFor(WidgetTester tester, String label) => tester.widget<IgnorePointer>(
        find.ancestor(of: subActionFab(label), matching: find.byType(IgnorePointer)).first,
      );

  group('QuickActionsFab', () {
    testWidgets('the sub-actions ignore pointer events until the FAB is opened', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(onBuy: () {}, onSell: () {}, onRebalance: () {}, onReports: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final ignorePointers = tester.widgetList<IgnorePointer>(ignorePointersInFab());
      expect(ignorePointers, isNotEmpty);
      expect(ignorePointers.every((w) => w.ignoring), isTrue);
    });

    testWidgets('tapping the main FAB opens the speed dial and stops ignoring the implemented actions', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(onBuy: () {}, onSell: () {}, onRebalance: () {}, onReports: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(mainFab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Investir/Ver Alocação are implemented — they become tappable.
      expect(ignorePointerFor(tester, 'Investir').ignoring, isFalse);
      expect(ignorePointerFor(tester, 'Ver Alocação').ignoring, isFalse);
      // Vender/Relatórios are `available: false` — still non-tappable even
      // with the dial open, so tapping can never silently do nothing.
      expect(ignorePointerFor(tester, 'Vender').ignoring, isTrue);
      expect(ignorePointerFor(tester, 'Relatórios').ignoring, isTrue);

      expect(find.text('Investir'), findsOneWidget);
      expect(find.text('Vender'), findsOneWidget);
      expect(find.text('Ver Alocação'), findsOneWidget);
      expect(find.text('Relatórios'), findsOneWidget);
      // Both unavailable actions carry the shared "coming soon" badge.
      expect(find.text('EM BREVE'), findsNWidgets(2));
    });

    testWidgets('tapping a sub-action fires its callback and closes the speed dial', (WidgetTester tester) async {
      var buyTapped = false;
      await tester.pumpWidget(buildTestableWidget(
        onBuy: () => buyTapped = true,
        onSell: () {},
        onRebalance: () {},
        onReports: () {},
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(mainFab); // open
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(subActionFab('Investir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(buyTapped, isTrue);
      final ignorePointers = tester.widgetList<IgnorePointer>(ignorePointersInFab());
      expect(ignorePointers.every((w) => w.ignoring), isTrue);
    });

    testWidgets('tapping the FAB again while open closes the speed dial', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(onBuy: () {}, onSell: () {}, onRebalance: () {}, onReports: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(mainFab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(ignorePointerFor(tester, 'Investir').ignoring, isFalse);

      await tester.tap(mainFab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final ignorePointers = tester.widgetList<IgnorePointer>(ignorePointersInFab());
      expect(ignorePointers.every((w) => w.ignoring), isTrue);
    });
  });
}
