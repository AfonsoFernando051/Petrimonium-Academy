import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/enums/pet_speech_bubble_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/comic_bubble_painter.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_comic_speech_bubble.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildWidget({
    required PetMessage message,
    VoidCallback? onDismiss,
    VoidCallback? onAction,
    PetSpeechBubbleState? overrideState,
    PetBubbleTailPosition tailPosition = PetBubbleTailPosition.bottomLeft,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: PetComicSpeechBubble(
            message: message,
            onDismiss: onDismiss ?? () {},
            onAction: onAction,
            overrideState: overrideState,
            tailPosition: tailPosition,
          ),
        ),
      ),
    );
  }

  group('PetComicSpeechBubble', () {
    testWidgets('renders badge, text, and close button correctly', (tester) async {
      const message = PetMessage(
        id: 'test_idle',
        context: PetContext.home,
        priority: PetMessagePriority.normal,
        trigger: PetMessageTrigger.pageEnter,
        textKey: 'COMPANION',
        mood: PetAnimationState.happy,
      );

      await tester.pumpWidget(buildWidget(message: message));
      await tester.pumpAndSettle();

      expect(find.byType(PetComicSpeechBubble), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('supports all 6 visual states (idle, guidance, success, encouragement, milestone, attention)',
        (tester) async {
      for (final state in PetSpeechBubbleState.values) {
        const message = PetMessage(
          id: 'test_state',
          context: PetContext.home,
          priority: PetMessagePriority.normal,
          trigger: PetMessageTrigger.pageEnter,
          textKey: 'COMPANION',
        );

        await tester.pumpWidget(
          buildWidget(message: message, overrideState: state),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PetComicSpeechBubble), findsOneWidget);
      }
    });

    testWidgets('renders action button when PetMessageAction is provided and responds to tap', (tester) async {
      bool actionTapped = false;
      const message = PetMessage(
        id: 'test_action',
        context: PetContext.home,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.levelUp,
        textKey: 'COMPANION',
        action: PetMessageAction(
          labelKey: 'CONTINUE',
          destination: PetContext.academy,
        ),
      );

      await tester.pumpWidget(
        buildWidget(
          message: message,
          onAction: () {
            actionTapped = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CONTINUE'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });

    testWidgets('handles different tail positions without error', (tester) async {
      const message = PetMessage(
        id: 'test_tail',
        context: PetContext.home,
        priority: PetMessagePriority.normal,
        trigger: PetMessageTrigger.pageEnter,
        textKey: 'COMPANION',
      );

      for (final tailPos in PetBubbleTailPosition.values) {
        await tester.pumpWidget(
          buildWidget(message: message, tailPosition: tailPos),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PetComicSpeechBubble), findsOneWidget);
      }
    });
  });
}
