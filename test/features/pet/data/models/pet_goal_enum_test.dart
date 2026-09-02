import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';

void main() {
  group('PetGoalEnumDisplay', () {
    test('every value has a non-empty label, emoji and icon', () {
      for (final goal in PetGoalEnum.values) {
        expect(goal.label, isNotEmpty);
        expect(goal.emoji, isNotEmpty);
        expect(goal.icon, isNotNull);
      }
    });

    test('labels are unique across all goals', () {
      final labels = PetGoalEnum.values.map((g) => g.label).toSet();
      expect(labels.length, PetGoalEnum.values.length);
    });
  });

  group('PetGoalEnumDisplay.fromName', () {
    test('resolves a matching name back to its enum value', () {
      for (final goal in PetGoalEnum.values) {
        expect(PetGoalEnumDisplay.fromName(goal.name), goal);
      }
    });

    test('falls back to investWithConfidence for an unknown or null name', () {
      expect(PetGoalEnumDisplay.fromName('bogus'), PetGoalEnum.investWithConfidence);
      expect(PetGoalEnumDisplay.fromName(null), PetGoalEnum.investWithConfidence);
    });
  });
}
