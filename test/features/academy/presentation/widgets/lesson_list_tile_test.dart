import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/lesson_list_tile.dart';

import '../../academy_test_fixtures.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable({required LessonStatus status, VoidCallback? onTap}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: LessonListTile(lesson: testLesson1, status: status, onTap: onTap),
      ),
    );
  }

  group('LessonListTile', () {
    testWidgets('renders lesson title and xp reward', (tester) async {
      await tester.pumpWidget(buildTestable(status: LessonStatus.available, onTap: () {}));

      expect(find.text(testLesson1.title), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('shows a check icon when completed', (tester) async {
      await tester.pumpWidget(buildTestable(status: LessonStatus.completed, onTap: () {}));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows a lock icon when locked and does not invoke onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(status: LessonStatus.locked, onTap: () => tapped = true));

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);

      await tester.tap(find.byType(LessonListTile), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('invokes onTap when available', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(status: LessonStatus.available, onTap: () => tapped = true));

      await tester.tap(find.byType(LessonListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
