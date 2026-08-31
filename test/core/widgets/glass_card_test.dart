import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

void main() {
  Widget wrap(Widget child, {ThemeData? theme}) =>
      MaterialApp(theme: theme ?? AppTheme.dark, home: Scaffold(body: child));

  group('GlassCard', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(wrap(const GlassCard(child: Text('inside'))));

      expect(find.text('inside'), findsOneWidget);
    });

    testWidgets('wraps content in a BackdropFilter for the glass blur', (tester) async {
      await tester.pumpWidget(wrap(const GlassCard(child: Text('inside'))));

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('applies a margin wrapper only when margin is provided', (tester) async {
      await tester.pumpWidget(wrap(const GlassCard(margin: EdgeInsets.all(8), child: Text('inside'))));

      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.any((c) => c.margin == const EdgeInsets.all(8)), isTrue);
    });

    testWidgets('explicit backgroundColor/borderColor override the resolved surface look', (tester) async {
      await tester.pumpWidget(wrap(GlassCard(
        backgroundColor: Colors.red,
        borderColor: Colors.yellow,
        child: const Text('inside'),
      )));

      // Find the Container that carries the BoxDecoration with our override colors.
      final decorated = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color == Colors.red);
      expect(decorated, isNotEmpty);
    });

    testWidgets('renders correctly across every CardSurface value in Light theme', (tester) async {
      for (final surface in CardSurface.values) {
        await tester.pumpWidget(wrap(
          GlassCard(surface: surface, child: const Text('inside')),
          theme: AppTheme.light,
        ));
        expect(find.text('inside'), findsOneWidget);
      }
    });
  });
}
