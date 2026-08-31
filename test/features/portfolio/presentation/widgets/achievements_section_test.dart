import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/achievement_card_widget.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/achievements_section.dart';

void main() {
  Widget buildTestableWidget(List<Achievement> achievements) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AchievementsSection(achievements: achievements)),
    );
  }

  const unlocked = Achievement(
    id: 'a1',
    title: 'First Trade',
    description: 'desc',
    icon: Icons.star,
    xpReward: 50,
    unlocked: true,
  );

  const locked = Achievement(
    id: 'a2',
    title: 'Diversified',
    description: 'desc',
    icon: Icons.pie_chart,
    xpReward: 30,
    unlocked: false,
  );

  group('AchievementsSection', () {
    testWidgets('renders unlocked/total count and one card per achievement', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget([unlocked, locked]));

      expect(find.textContaining('CONQUISTAS'), findsOneWidget);
      expect(find.textContaining('1/2'), findsOneWidget);
      expect(find.byType(AchievementCardWidget), findsNWidgets(2));
    });

    testWidgets('renders zero of zero count when list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget([]));

      expect(find.textContaining('0/0'), findsOneWidget);
      expect(find.byType(AchievementCardWidget), findsNothing);
    });
  });
}
