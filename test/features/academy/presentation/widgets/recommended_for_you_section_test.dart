import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_recommendation.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/presentation/widgets/recommended_for_you_section.dart';

import '../../academy_test_fixtures.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('RecommendedForYouSection', () {
    testWidgets('renders nothing for an empty recommendations list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: RecommendedForYouSection(recommendations: const [], onTapLesson: (_) {}),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text(Translator.translate(AppStrings.academyRecommendedSectionLabel)), findsNothing);
    });

    testWidgets('renders one card per recommendation and invokes onTapLesson', (tester) async {
      Lesson? tapped;
      final recommendations = [
        const AcademyRecommendation(
          type: RecommendationType.continueLearning,
          lesson: testLesson1,
          reasonKey: AppStrings.academyRecommendationContinueReason,
        ),
        const AcademyRecommendation(
          type: RecommendationType.review,
          lesson: testLesson2,
          reasonKey: AppStrings.academyRecommendationReviewReason,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: RecommendedForYouSection(
              recommendations: recommendations,
              onTapLesson: (lesson) => tapped = lesson,
            ),
          ),
        ),
      );

      expect(find.text(testLesson1.title), findsOneWidget);
      expect(find.text(testLesson2.title), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      await tester.tap(find.text(testLesson1.title));
      await tester.pump();

      expect(tapped, testLesson1);
    });
  });
}
