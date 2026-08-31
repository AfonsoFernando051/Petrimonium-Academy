import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';

void main() {
  group('MasteryTier', () {
    test('has exactly the 4 expected tiers, in order', () {
      expect(MasteryTier.values, [
        MasteryTier.exploring,
        MasteryTier.understanding,
        MasteryTier.applying,
        MasteryTier.mastering,
      ]);
    });
  });
}
