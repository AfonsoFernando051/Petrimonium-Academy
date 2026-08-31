import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/presentation/widgets/lesson_complete_card.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable({VoidCallback? onContinue, VoidCallback? onBackToAcademy}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: LessonCompleteCard(
          lessonTitle: 'My Lesson',
          xpEarned: 42,
          onContinue: onContinue ?? () {},
          onBackToAcademy: onBackToAcademy ?? () {},
        ),
      ),
    );
  }

  group('LessonCompleteCard', () {
    testWidgets('renders lesson title and xp earned', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('My Lesson'), findsOneWidget);
      expect(find.textContaining('42'), findsWidgets);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('invokes onContinue when the continue button is tapped', (tester) async {
      var continued = false;
      await tester.pumpWidget(buildTestable(onContinue: () => continued = true));

      await tester.tap(find.byType(GameButton));
      await tester.pump();

      expect(continued, isTrue);
    });

    testWidgets('invokes onBackToAcademy when the text button is tapped', (tester) async {
      var wentBack = false;
      await tester.pumpWidget(buildTestable(onBackToAcademy: () => wentBack = true));

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(wentBack, isTrue);
    });
  });
}
