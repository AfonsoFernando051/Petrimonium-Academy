import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';

void main() {
  group('DI', () {
    test('every static service field is non-null at class load', () {
      // DI is a plain static service locator (no constructor) — the real
      // regression risk here is a typo'd/incomplete field initializer that
      // would throw or leave a field null the first time any class member is
      // touched. Reading every field is enough to trigger that.
      expect(DI.authRepository, isNotNull);
      expect(DI.onboardingRepository, isNotNull);
      expect(DI.onboardingStateRepository, isNotNull);
      expect(DI.petRepository, isNotNull);
      expect(DI.gamificationRepository, isNotNull);
      expect(DI.mascotRepository, isNotNull);
      expect(DI.petPreferencesRepository, isNotNull);
      expect(DI.petCompanionPreferencesRepository, isNotNull);
      expect(DI.settingsRepository, isNotNull);
      expect(DI.portfolioRepository, isNotNull);
      expect(DI.achievementsLocalRepository, isNotNull);
      expect(DI.achievementsRepository, isNotNull);
      expect(DI.missionsRepository, isNotNull);
      expect(DI.academyProgressRepository, isNotNull);
      expect(DI.academyRemoteDataSource, isNotNull);
      expect(DI.academyCatalogRepository, isNotNull);
      expect(DI.mentorChatRepository, isNotNull);
    });
  });
}
