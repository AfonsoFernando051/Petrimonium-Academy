import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_evolution_rule.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

void main() {
  group('PetEvolutionRule.isSatisfiedBy', () {
    test('is satisfied exactly at the threshold', () {
      const rule = PetEvolutionRule(stage: PetEvolutionStage.teenDog, minXp: 100);
      expect(rule.isSatisfiedBy(xp: 100), isTrue);
    });

    test('is satisfied above the threshold', () {
      const rule = PetEvolutionRule(stage: PetEvolutionStage.teenDog, minXp: 100);
      expect(rule.isSatisfiedBy(xp: 101), isTrue);
    });

    test('is not satisfied below the threshold', () {
      const rule = PetEvolutionRule(stage: PetEvolutionStage.teenDog, minXp: 100);
      expect(rule.isSatisfiedBy(xp: 99), isFalse);
    });
  });

  test('copyWith overrides only the given fields', () {
    const rule = PetEvolutionRule(stage: PetEvolutionStage.babyDog, minXp: 0);
    final updated = rule.copyWith(minXp: 50);

    expect(updated.stage, PetEvolutionStage.babyDog);
    expect(updated.minXp, 50);
  });

  test('equality and hashCode are based on stage and minXp', () {
    const a = PetEvolutionRule(stage: PetEvolutionStage.adultDog, minXp: 300);
    const b = PetEvolutionRule(stage: PetEvolutionStage.adultDog, minXp: 300);
    const c = PetEvolutionRule(stage: PetEvolutionStage.adultDog, minXp: 301);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == c, isFalse);
  });

  group('PetEvolutionRule.defaultRules', () {
    test('has exactly 9 rules, one per evolution stage, in ascending order', () {
      expect(PetEvolutionRule.defaultRules, hasLength(9));
      expect(
        PetEvolutionRule.defaultRules.map((r) => r.stage).toList(),
        PetEvolutionStage.values,
      );
    });

    test('minXp is strictly increasing and starts at 0', () {
      final rules = PetEvolutionRule.defaultRules;
      expect(rules.first.minXp, 0);
      for (var i = 1; i < rules.length; i++) {
        expect(rules[i].minXp, greaterThan(rules[i - 1].minXp));
      }
    });
  });
}
