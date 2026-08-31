import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';
import 'package:petrimonium/features/academy/presentation/widgets/mastery_bar_row.dart';

import '../../academy_test_fixtures.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('MasteryBarRow', () {
    testWidgets('renders school title, progress percent and mastery percent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: MasteryBarRow(
              school: testSchool,
              percent: 0.75,
              masteryPercent: 0.5,
              masteryTier: MasteryTier.applying,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(testSchool.title), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.textContaining('50%'), findsOneWidget);
    });
  });
}
