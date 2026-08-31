import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';

void main() {
  const achievement = Achievement(
    id: 'first_investment',
    title: 'First Investment',
    description: 'desc',
    icon: Icons.star,
    xpReward: 10,
    unlocked: true,
  );

  group('AppEvent subclasses', () {
    test('AchievementUnlockedEvent carries the given achievement', () {
      const event = AchievementUnlockedEvent(achievement);

      expect(event.achievement, achievement);
    });

    test('PetEvolvedEvent carries the new stage', () {
      const event = PetEvolvedEvent(PetEvolutionStage.adultDog);

      expect(event.newStage, PetEvolutionStage.adultDog);
    });

    test('UserLeveledUpEvent carries the new level', () {
      const event = UserLeveledUpEvent(7);

      expect(event.newLevel, 7);
    });

    test('LessonCompletedEvent carries the lesson id', () {
      const event = LessonCompletedEvent('lesson_1');

      expect(event.lessonId, 'lesson_1');
    });

    test('XpGainedEvent carries the amount and the new total', () {
      const event = XpGainedEvent(amount: 20, newTotalXp: 120);

      expect(event.amount, 20);
      expect(event.newTotalXp, 120);
    });

    test('DifficultyDetectedEvent carries the school title', () {
      const event = DifficultyDetectedEvent('Renda Fixa');

      expect(event.schoolTitle, 'Renda Fixa');
    });

    test('SchoolMasteredEvent carries the school title', () {
      const event = SchoolMasteredEvent('Renda Fixa');

      expect(event.schoolTitle, 'Renda Fixa');
    });

    test('FirstInvestmentAddedEvent is a const, no-payload event', () {
      const event = FirstInvestmentAddedEvent();

      expect(event, isA<AppEvent>());
    });

    test('HighConcentrationDetectedEvent carries the ticker and percent', () {
      const event = HighConcentrationDetectedEvent(ticker: 'PETR4', percent: 55);

      expect(event.ticker, 'PETR4');
      expect(event.percent, 55);
    });

    test('MissionCompletedEvent carries the resolved mission title', () {
      const event = MissionCompletedEvent('Aula do Dia');

      expect(event.missionTitle, 'Aula do Dia');
    });

    test('every event is an AppEvent', () {
      const events = <AppEvent>[
        AchievementUnlockedEvent(achievement),
        PetEvolvedEvent(PetEvolutionStage.babyDog),
        UserLeveledUpEvent(1),
        LessonCompletedEvent('l'),
        XpGainedEvent(amount: 1, newTotalXp: 1),
        DifficultyDetectedEvent('s'),
        SchoolMasteredEvent('s'),
        FirstInvestmentAddedEvent(),
        HighConcentrationDetectedEvent(ticker: 'PETR4', percent: 55),
        MissionCompletedEvent('m'),
      ];

      for (final event in events) {
        expect(event, isA<AppEvent>());
      }
    });
  });
}
