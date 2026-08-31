import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/school_card.dart';

import '../../academy_test_fixtures.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable({
    required SchoolStatus status,
    VoidCallback? onTap,
    List<String> missingPrerequisites = const [],
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: SchoolCard(
          school: testSchool,
          status: status,
          masteryPercent: 0.5,
          onTap: onTap,
          missingPrerequisites: missingPrerequisites,
        ),
      ),
    );
  }

  group('SchoolCard', () {
    testWidgets('renders school title/description and progress when available', (tester) async {
      await tester.pumpWidget(buildTestable(status: SchoolStatus.available));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(testSchool.title), findsOneWidget);
      expect(find.text(testSchool.description), findsOneWidget);
    });

    testWidgets('shows a lock icon when comingSoon', (tester) async {
      await tester.pumpWidget(buildTestable(status: SchoolStatus.comingSoon));
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('explains the missing prerequisite when locked', (tester) async {
      await tester.pumpWidget(buildTestable(status: SchoolStatus.locked, missingPrerequisites: ['Fundamentos de Investimento']));
      await tester.pump();

      expect(find.text('Conclua Fundamentos de Investimento primeiro'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows no prerequisite explanation when comingSoon (no real prerequisite to name)', (tester) async {
      await tester.pumpWidget(buildTestable(status: SchoolStatus.comingSoon, missingPrerequisites: const []));
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('invokes onTap when tapped and available', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(status: SchoolStatus.available, onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(SchoolCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
