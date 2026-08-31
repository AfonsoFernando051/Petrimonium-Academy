import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/mission_card_widget.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/missions_section.dart';

void main() {
  Widget buildTestableWidget(List<MissionStatus> missions) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: MissionsSection(missions: missions)),
    );
  }

  const completed = MissionStatus(
    code: 'daily_complete_lesson',
    period: MissionPeriod.daily,
    periodKey: '2026-08-19',
    progress: 1,
    target: 1,
    xpReward: 30,
    completed: true,
  );
  const inProgress = MissionStatus(
    code: 'daily_complete_two_lessons',
    period: MissionPeriod.daily,
    periodKey: '2026-08-19',
    progress: 1,
    target: 2,
    xpReward: 50,
    completed: false,
  );

  group('MissionsSection', () {
    testWidgets('renders completed/total count and one card per mission', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget([completed, inProgress]));

      expect(find.text('MISSÕES · 1/2'), findsOneWidget);
      expect(find.byType(MissionCardWidget), findsNWidgets(2));
    });

    testWidgets('renders nothing (SizedBox.shrink) for an empty mission list', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget([]));

      expect(find.byType(MissionCardWidget), findsNothing);
      expect(find.textContaining('MISSÕES'), findsNothing);
    });
  });
}
