import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));
  }

  group('AcademyProgressBar', () {
    testWidgets('renders and animates toward the given progress without pumpAndSettle', (tester) async {
      await tester.pumpWidget(buildTestable(const AcademyProgressBar(progress: 0.5)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FractionallySizedBox), findsOneWidget);
      final box = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(box.widthFactor, closeTo(0.5, 0.01));
    });

    testWidgets('clamps progress above 1.0', (tester) async {
      await tester.pumpWidget(buildTestable(const AcademyProgressBar(progress: 2.0)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final box = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(box.widthFactor, closeTo(1.0, 0.01));
    });

    testWidgets('clamps progress below 0.0', (tester) async {
      await tester.pumpWidget(buildTestable(const AcademyProgressBar(progress: -1.0)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final box = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(box.widthFactor, closeTo(0.0, 0.01));
    });

    testWidgets('uses a flat color instead of the default gradient when color is given', (tester) async {
      await tester.pumpWidget(buildTestable(const AcademyProgressBar(progress: 0.3, color: AppColors.goldenBorder)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final containers = find.descendant(
        of: find.byType(FractionallySizedBox),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containers.first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.goldenBorder);
      expect(decoration.gradient, isNull);
    });
  });
}
