import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';

void main() {
  test('has the 6 expected animation states', () {
    expect(PetAnimationState.values, [
      PetAnimationState.idle,
      PetAnimationState.celebrate,
      PetAnimationState.think,
      PetAnimationState.sleep,
      PetAnimationState.victory,
      PetAnimationState.happy,
    ]);
  });

  test('assetKey matches the enum name for every state', () {
    for (final state in PetAnimationState.values) {
      expect(state.assetKey, state.name);
    }
  });
}
