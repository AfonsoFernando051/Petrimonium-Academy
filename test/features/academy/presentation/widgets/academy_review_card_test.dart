import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_review_card.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable(VoidCallback onStart) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AcademyReviewCard(lessonCount: 3, estimatedMinutes: 6, onStart: onStart),
      ),
    );
  }

  group('AcademyReviewCard', () {
    testWidgets('renders lesson count/minutes and a start action — no GameButton (secondary, not primary)', (tester) async {
      await tester.pumpWidget(buildTestable(() {}));

      // Deliberately not a GameButton (see class doc) — this is a secondary
      // action, so it must not visually compete with AcademyContinueCard's
      // primary CTA.
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.textContaining('3'), findsWidgets);
      expect(find.textContaining('6'), findsWidgets);
    });

    testWidgets('invokes onStart when the row is tapped', (tester) async {
      var started = false;
      await tester.pumpWidget(buildTestable(() => started = true));

      await tester.tap(find.byType(AcademyReviewCard));
      await tester.pump();

      expect(started, isTrue);
    });
  });
}
