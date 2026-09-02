import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';

void main() {
  group('CosmicBackground', () {
    testWidgets('renders its child on the cosmic gradient plus starfield (dark theme)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: CosmicBackground(child: Text('content')),
          ),
        ),
      );
      // CosmicBackground has a repeating twinkle AnimationController — never
      // pumpAndSettle here.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('content'), findsOneWidget);
      final decoration = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, [AppColors.spaceDark, AppColors.spacePurple]);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders its child on the light theme equivalent gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: CosmicBackground(child: Text('content')),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('content'), findsOneWidget);
    });
  });
}
