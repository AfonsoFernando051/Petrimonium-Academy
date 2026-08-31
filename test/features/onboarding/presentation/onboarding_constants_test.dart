import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/onboarding/presentation/onboarding_constants.dart';

void main() {
  test('kStandardLessonXpReward matches the real per-lesson XP value', () {
    expect(kStandardLessonXpReward, 20);
  });
}
