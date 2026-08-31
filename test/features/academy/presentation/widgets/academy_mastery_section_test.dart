import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_mastery_section.dart';
import 'package:petrimonium/features/academy/presentation/widgets/mastery_bar_row.dart';

import '../../academy_test_fixtures.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('AcademyMasterySection', () {
    testWidgets('renders one MasteryBarRow per school', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: AcademyMasterySection(
              schools: const [testSchool],
              masteryFor: (school) => 0.6,
              realMasteryFor: (school) => 0.4,
              masteryTierFor: (school) => MasteryTier.understanding,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MasteryBarRow), findsOneWidget);
      expect(find.text(testSchool.title), findsOneWidget);
    });

    testWidgets('renders nothing extra for an empty schools list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: AcademyMasterySection(
              schools: const [],
              masteryFor: (school) => 0.0,
              realMasteryFor: (school) => 0.0,
              masteryTierFor: (school) => MasteryTier.exploring,
            ),
          ),
        ),
      );

      expect(find.byType(MasteryBarRow), findsNothing);
    });
  });
}
