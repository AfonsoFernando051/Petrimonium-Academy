import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

void main() {
  group('AppEventBus', () {
    test('instance is a singleton', () {
      expect(AppEventBus.instance, same(AppEventBus.instance));
    });

    test('emit delivers the event to a subscriber', () async {
      final events = <AppEvent>[];
      final subscription = AppEventBus.instance.stream.listen(events.add);

      AppEventBus.instance.emit(const UserLeveledUpEvent(5));
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect((events.single as UserLeveledUpEvent).newLevel, 5);

      await subscription.cancel();
    });

    test('emit fans out to every active subscriber', () async {
      final first = <AppEvent>[];
      final second = <AppEvent>[];
      final sub1 = AppEventBus.instance.stream.listen(first.add);
      final sub2 = AppEventBus.instance.stream.listen(second.add);

      AppEventBus.instance.emit(const LessonCompletedEvent('lesson-1'));
      await Future<void>.delayed(Duration.zero);

      expect(first, hasLength(1));
      expect(second, hasLength(1));

      await sub1.cancel();
      await sub2.cancel();
    });

    test('a cancelled subscription no longer receives events', () async {
      final events = <AppEvent>[];
      final subscription = AppEventBus.instance.stream.listen(events.add);
      await subscription.cancel();

      AppEventBus.instance.emit(const XpGainedEvent(amount: 10, newTotalXp: 110));
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
    });

    test('carries the payload for every declared event type', () async {
      final events = <AppEvent>[];
      final subscription = AppEventBus.instance.stream.listen(events.add);

      AppEventBus.instance.emit(const PetEvolvedEvent(PetEvolutionStage.teenDog));
      AppEventBus.instance.emit(const DifficultyDetectedEvent('Vida Financeira'));
      AppEventBus.instance.emit(const SchoolMasteredEvent('Vida Financeira'));
      await Future<void>.delayed(Duration.zero);

      expect(events.whereType<PetEvolvedEvent>(), hasLength(1));
      expect(events.whereType<DifficultyDetectedEvent>().single.schoolTitle, 'Vida Financeira');
      expect(events.whereType<SchoolMasteredEvent>().single.schoolTitle, 'Vida Financeira');

      await subscription.cancel();
    });
  });
}
