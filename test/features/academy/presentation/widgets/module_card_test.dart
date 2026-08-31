import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/module_card.dart';

import '../../academy_test_fixtures.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable({
    required ModuleStatus status,
    int completedLessons = 0,
    VoidCallback? onTap,
    List<String> missingPrerequisites = const [],
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: ModuleCard(
          module: testModule,
          status: status,
          completedLessons: completedLessons,
          onTap: onTap,
          missingPrerequisites: missingPrerequisites,
        ),
      ),
    );
  }

  group('ModuleCard', () {
    testWidgets('renders module title/description and progress when available', (tester) async {
      await tester.pumpWidget(buildTestable(status: ModuleStatus.available));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(testModule.title), findsOneWidget);
      expect(find.text(testModule.description), findsOneWidget);
    });

    testWidgets('shows completed/total lesson count when inProgress', (tester) async {
      await tester.pumpWidget(buildTestable(status: ModuleStatus.inProgress, completedLessons: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('1'), findsWidgets);
    });

    testWidgets('shows a lock icon when comingSoon and hides progress', (tester) async {
      await tester.pumpWidget(buildTestable(status: ModuleStatus.comingSoon));
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('explains the missing prerequisite when locked', (tester) async {
      await tester.pumpWidget(
        buildTestable(status: ModuleStatus.locked, missingPrerequisites: ['Fundamentos do Dinheiro']),
      );
      await tester.pump();

      expect(find.text('Conclua Fundamentos do Dinheiro primeiro'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows no prerequisite explanation when comingSoon (no real prerequisite to name)', (tester) async {
      await tester.pumpWidget(buildTestable(status: ModuleStatus.comingSoon, missingPrerequisites: const []));
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('invokes onTap when tapped and available', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(status: ModuleStatus.available, onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(ModuleCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not invoke onTap when locked', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(status: ModuleStatus.locked, onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(ModuleCard), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
