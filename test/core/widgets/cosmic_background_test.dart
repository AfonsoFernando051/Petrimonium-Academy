import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';

void main() {
  group('CosmicBackground', () {
    testWidgets('renders its child without crashing given a valid assetPath (dark theme)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: CosmicBackground(child: Text('content')),
          ),
        ),
      );
      // CosmicBackground has two repeating AnimationControllers — never
      // pumpAndSettle here.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('renders its child without crashing in light theme (aurora background)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: CosmicBackground(child: Text('content')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('light theme with showArtworkInLightMode renders the image-based background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: CosmicBackground(showArtworkInLightMode: true, child: Text('content')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('invokes errorBuilder when the asset fails to load', (tester) async {
      var errorBuilderCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CosmicBackground(
              assetPath: 'assets/images/does_not_exist.png',
              errorBuilder: (context, error, stackTrace) {
                errorBuilderCalled = true;
                return const SizedBox.shrink();
              },
              child: const Text('content'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(errorBuilderCalled, isTrue);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('renders for every intensity preset without crashing', (tester) async {
      for (final intensity in BackgroundIntensity.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: CosmicBackground(intensity: intensity, child: const Text('content')),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('content'), findsOneWidget);
      }
    });

    testWidgets('updating intensity on an already-mounted instance does not crash', (tester) async {
      Widget build(BackgroundIntensity intensity) {
        return MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CosmicBackground(intensity: intensity, child: const Text('content')),
          ),
        );
      }

      await tester.pumpWidget(build(BackgroundIntensity.immersive));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(build(BackgroundIntensity.focus));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('content'), findsOneWidget);
    });
  });
}
