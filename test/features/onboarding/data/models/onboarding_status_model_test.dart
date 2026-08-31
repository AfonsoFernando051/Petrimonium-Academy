import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/onboarding/data/models/onboarding_status_model.dart';

void main() {
  group('OnboardingStatusModel.fromJson', () {
    test('parses hasAnswered and profile from a complete json map', () {
      final model = OnboardingStatusModel.fromJson(const {
        'hasAnswered': true,
        'profile': 'moderate',
      });

      expect(model.hasAnswered, isTrue);
      expect(model.profile, 'moderate');
    });

    test('parses a null profile when hasAnswered is false', () {
      final model = OnboardingStatusModel.fromJson(const {
        'hasAnswered': false,
        'profile': null,
      });

      expect(model.hasAnswered, isFalse);
      expect(model.profile, isNull);
    });
  });

  test('const constructor sets fields directly', () {
    const model = OnboardingStatusModel(hasAnswered: true, profile: 'conservative');

    expect(model.hasAnswered, isTrue);
    expect(model.profile, 'conservative');
  });
}
