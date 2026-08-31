import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/pet_hero_capsule.dart';

void main() {
  Widget buildTestableWidget({double size = 250, Widget? child}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PetHeroCapsule(
          size: size,
          child: child ?? const Icon(Icons.pets, key: Key('inner')),
        ),
      ),
    );
  }

  group('PetHeroCapsule', () {
    testWidgets('renders its child inside the capsule', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Has a repeating AnimationController (breathe/float) — never call
      // pumpAndSettle, a bounded pump is enough to lay out.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('inner')), findsOneWidget);
    });

    testWidgets('sizes the capsule container to the given size', (tester) async {
      await tester.pumpWidget(buildTestableWidget(size: 180));
      await tester.pump();

      final size = tester.getSize(find.byType(Container).first);
      expect(size, const Size(180, 180));
    });

    testWidgets('does not throw across multiple animation frames', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
    });
  });
}
