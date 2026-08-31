import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/achievement_card_widget.dart';

void main() {
  Widget buildTestableWidget(Achievement achievement) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AchievementCardWidget(achievement: achievement)),
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
    icon: Icons.star,
    xpReward: 30,
    unlocked: false,
  );

  group('AchievementCardWidget', () {
    testWidgets('renders title, xp reward and its own icon when unlocked', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(unlocked));

      expect(find.text('First Trade'), findsOneWidget);
      expect(find.text('+50 XP'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('renders a lock icon and title when locked', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(locked));

      expect(find.text('Diversified'), findsOneWidget);
      expect(find.text('+30 XP'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });
  });
}
