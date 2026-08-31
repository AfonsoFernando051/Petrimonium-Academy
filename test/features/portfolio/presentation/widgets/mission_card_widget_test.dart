import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/mission_card_widget.dart';

void main() {
  Widget buildTestableWidget(MissionStatus mission) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: MissionCardWidget(mission: mission)),
    );
  }

  group('MissionCardWidget', () {
    testWidgets('renders known mission title/description, progress and XP reward', (WidgetTester tester) async {
      const mission = MissionStatus(
        code: 'daily_complete_lesson',
        period: MissionPeriod.daily,
        periodKey: '2026-08-19',
        progress: 0,
        target: 1,
        xpReward: 30,
        completed: false,
      );

      await tester.pumpWidget(buildTestableWidget(mission));

      expect(find.text('Aula do Dia'), findsOneWidget);
      expect(find.text('Complete 1 aula hoje.'), findsOneWidget);
      expect(find.text('0/1'), findsOneWidget);
      expect(find.text('+30 XP'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('shows a check icon and completed styling when completed', (WidgetTester tester) async {
      const mission = MissionStatus(
        code: 'daily_complete_lesson',
        period: MissionPeriod.daily,
        periodKey: '2026-08-19',
        progress: 1,
        target: 1,
        xpReward: 30,
        completed: true,
      );

      await tester.pumpWidget(buildTestableWidget(mission));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('1/1'), findsOneWidget);
    });

    testWidgets('falls back to the raw code for an unknown mission code, without throwing', (WidgetTester tester) async {
      const mission = MissionStatus(
        code: 'unknown_mission',
        period: MissionPeriod.weekly,
        periodKey: '2026-W34',
        progress: 2,
        target: 5,
        xpReward: 10,
        completed: false,
      );

      await tester.pumpWidget(buildTestableWidget(mission));

      expect(find.text('unknown_mission'), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);
    });

    testWidgets('does not throw when target is 0 (avoids division by zero)', (WidgetTester tester) async {
      const mission = MissionStatus(
        code: 'daily_complete_lesson',
        period: MissionPeriod.daily,
        periodKey: '2026-08-19',
        progress: 0,
        target: 0,
        xpReward: 0,
        completed: false,
      );

      await tester.pumpWidget(buildTestableWidget(mission));

      expect(find.text('0/0'), findsOneWidget);
    });
  });
}
