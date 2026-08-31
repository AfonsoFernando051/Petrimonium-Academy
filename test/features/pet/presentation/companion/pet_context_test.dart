import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';

void main() {
  test('has exactly the 5 real top-level destinations', () {
    expect(PetContext.values, [
      PetContext.home,
      PetContext.academy,
      PetContext.portfolio,
      PetContext.mentor,
      PetContext.profile,
    ]);
  });
}
