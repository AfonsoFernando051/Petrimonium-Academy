import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/features/academy/domain/services/academy_pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/behavior/core_pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/behavior/pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/portfolio/domain/services/portfolio_pet_behavior.dart';

/// PRD guardrail (§10.3, §12.2, FR-MEN-002): the Pet's celebratory moods are
/// reserved for educational milestones. A financial event may be acknowledged,
/// but never with the animation a finished lesson gets.
///
/// Academy composes several [PetBehavior]s and takes the first non-null answer,
/// so the guardrail is checked against *every* registered behavior — a
/// financial event must not be able to find a celebratory reaction anywhere in
/// the chain.
void main() {
  /// `happy` counts: the PRD names "comemoração/felicidade" together.
  const celebratory = {
    PetAnimationState.celebrate,
    PetAnimationState.victory,
    PetAnimationState.happy,
  };

  const behaviors = <PetBehavior>[
    CorePetBehavior(),
    AcademyPetBehavior(),
    PortfolioPetBehavior(),
  ];

  const financialEvents = <AppEvent>[
    FirstInvestmentAddedEvent(),
    HighConcentrationDetectedEvent(ticker: 'PETR4', percent: 62.5),
  ];

  group('no registered behavior celebrates a financial event', () {
    for (final event in financialEvents) {
      for (final behavior in behaviors) {
        test('${behavior.runtimeType} on ${event.runtimeType}', () {
          final message = behavior.onEvent(event);

          // null is a perfectly good answer — this behavior simply doesn't
          // speak for that event.
          if (message == null) return;

          expect(
            celebratory.contains(message.mood),
            isFalse,
            reason: '${behavior.runtimeType} answered ${event.runtimeType} with '
                '${message.mood}, which the PRD reserves for educational milestones',
          );
        });
      }
    }

    test('every event listed here really is financial', () {
      for (final event in financialEvents) {
        expect(event.isFinancial, isTrue,
            reason: '${event.runtimeType} is in the financial list but not marked isFinancial');
      }
    });
  });

  test('the first investment is still acknowledged and still bridges to learning', () {
    final message = const PortfolioPetBehavior().onEvent(const FirstInvestmentAddedEvent());

    expect(message, isNotNull, reason: 'muting the mood must not mute the message');
    expect(message!.mood, PetAnimationState.idle);
    expect(message.action, isNotNull, reason: 'the hand-off into Academy is the point of it');
  });

  test('educational milestones are still allowed to celebrate', () {
    // The guardrail must not be satisfied by muting the Pet everywhere — that
    // would trade one PRD violation for another.
    final reactions = behaviors
        .map((b) => b.onEvent(const LessonCompletedEvent('l1')))
        .whereType<PetMessage>()
        .toList();

    expect(reactions, isNotEmpty, reason: 'a finished lesson should still get a reaction');
    expect(
      reactions.any((m) => celebratory.contains(m.mood)),
      isTrue,
      reason: 'at least one behavior should still celebrate a completed lesson',
    );
  });
}
