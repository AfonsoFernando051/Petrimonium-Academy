import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/mission_reward_card.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({
    required String title,
    required int xp,
    bool completed = true,
    String? eyebrow,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: MissionRewardCard(
          title: title,
          xp: xp,
          completed: completed,
          eyebrow: eyebrow,
        ),
      ),
    );
  }

  group('MissionRewardCard', () {
    testWidgets('renders the title and the default "Mission Complete" eyebrow when completed', (tester) async {
      await tester.pumpWidget(buildTestableWidget(title: 'Aprenda sobre juros compostos', xp: 20));
      await tester.pump();
      // Settle the XP count-up TweenAnimationBuilder (900ms).
      await tester.pump(const Duration(milliseconds: 950));

      expect(find.text('Aprenda sobre juros compostos'), findsOneWidget);
      expect(find.text('Missão Concluída'), findsOneWidget);
      expect(find.text('+20 XP'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    });

    testWidgets('shows a track_changes icon instead of a trophy when not completed', (tester) async {
      await tester.pumpWidget(buildTestableWidget(title: 'Upcoming mission', xp: 20, completed: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 950));

      expect(find.byIcon(Icons.track_changes_rounded), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
    });

    testWidgets('overrides the eyebrow text when one is supplied', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        title: 'Upcoming mission',
        xp: 20,
        completed: false,
        eyebrow: 'Sua primeira missão',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 950));

      expect(find.text('Sua primeira missão'), findsOneWidget);
      expect(find.text('Missão Concluída'), findsNothing);
    });
  });
}
