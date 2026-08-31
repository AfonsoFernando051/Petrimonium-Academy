import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/module_chip.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';

import '../../features/academy/academy_test_fixtures.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));
  }

  group('ModuleChip horizontal layout', () {
    testWidgets('renders the module icon and title', (tester) async {
      await tester.pumpWidget(buildTestable(const ModuleChip(module: testModule)));

      expect(find.text(testModule.title), findsOneWidget);
      expect(find.byIcon(testModule.icon), findsOneWidget);
    });
  });

  group('ModuleChip vertical layout', () {
    testWidgets('renders unaccented when status is null', (tester) async {
      await tester.pumpWidget(
        buildTestable(const ModuleChip(module: testModule, layout: ModuleChipLayout.vertical)),
      );

      expect(find.text(testModule.title), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('shows a completion badge when completed', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const ModuleChip(module: testModule, layout: ModuleChipLayout.vertical, status: ModuleStatus.completed),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows completed/total lessons when inProgress', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const ModuleChip(
            module: testModule,
            layout: ModuleChipLayout.vertical,
            status: ModuleStatus.inProgress,
            completedLessons: 1,
          ),
        ),
      );

      expect(find.text('1/${testModule.lessonIds.length}'), findsOneWidget);
    });

    testWidgets('invokes onTap when available', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestable(
          ModuleChip(
            module: testModule,
            layout: ModuleChipLayout.vertical,
            status: ModuleStatus.available,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ModuleChip));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not invoke onTap when comingSoon/locked', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestable(
          ModuleChip(
            module: testModule,
            layout: ModuleChipLayout.vertical,
            status: ModuleStatus.comingSoon,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ModuleChip), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
