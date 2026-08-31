import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/achievement_celebration_overlay.dart';

void main() {
  Widget buildTestableWidget(List<Achievement> achievements, VoidCallback onDismiss) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AchievementCelebrationOverlay(achievements: achievements, onDismiss: onDismiss),
      ),
    );
  }

  const achievement1 = Achievement(
    id: 'a1',
    title: 'First Trade',
    description: 'Comprou seu primeiro ativo',
    icon: Icons.star,
    xpReward: 50,
    unlocked: true,
  );

  const achievement2 = Achievement(
    id: 'a2',
    title: 'Diversified',
    description: 'Diversificou a carteira',
    icon: Icons.pie_chart,
    xpReward: 30,
    unlocked: true,
  );

  group('AchievementCelebrationOverlay', () {
    testWidgets('renders singular title, the achievement row and total XP for one achievement', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget([achievement1], () {}));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Conquista Desbloqueada!'), findsOneWidget);
      expect(find.text('First Trade'), findsOneWidget);
      expect(find.text('Comprou seu primeiro ativo'), findsOneWidget);
      expect(find.text('+50 XP'), findsOneWidget);
    });

    testWidgets('renders plural title and sums XP across multiple achievements', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget([achievement1, achievement2], () {}));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Conquistas Desbloqueadas!'), findsOneWidget);
      expect(find.text('First Trade'), findsOneWidget);
      expect(find.text('Diversified'), findsOneWidget);
      expect(find.text('+80 XP'), findsOneWidget);
    });

    testWidgets('invokes onDismiss when tapped outside the card', (WidgetTester tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildTestableWidget([achievement1], () => dismissed = true));
      await tester.pump(const Duration(milliseconds: 700));

      // Tap near the top-left corner of the screen, outside the centered card.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('auto-dismisses after 4 seconds', (WidgetTester tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildTestableWidget([achievement1], () => dismissed = true));
      await tester.pump(const Duration(milliseconds: 700));

      expect(dismissed, isFalse);
      await tester.pump(const Duration(seconds: 4));

      expect(dismissed, isTrue);
    });
  });
}
