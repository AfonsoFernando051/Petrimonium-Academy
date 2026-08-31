import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_domain_card.dart';

import '../../academy_test_fixtures.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable({required SchoolStatus status, VoidCallback? onTap}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AcademyDomainCard(
          domain: testDomain,
          status: status,
          masteryPercent: 0.4,
          onTap: onTap,
        ),
      ),
    );
  }

  group('AcademyDomainCard', () {
    testWidgets('renders domain title/description and progress for an available domain', (tester) async {
      await tester.pumpWidget(buildTestable(status: SchoolStatus.available, onTap: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(testDomain.title), findsOneWidget);
      expect(find.text(testDomain.description), findsOneWidget);
      expect(find.byIcon(testDomain.icon), findsOneWidget);
    });

    testWidgets('shows a lock icon and hides progress when comingSoon', (tester) async {
      await tester.pumpWidget(buildTestable(status: SchoolStatus.comingSoon, onTap: () {}));
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('invokes onTap when tapped and available', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(status: SchoolStatus.available, onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(AcademyDomainCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not invoke onTap when locked', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(status: SchoolStatus.locked, onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(AcademyDomainCard), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
