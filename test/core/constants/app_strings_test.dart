import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';

void main() {
  group('AppStrings', () {
    test('every key is a non-empty string matching its own field name', () {
      // AppStrings values are keys into Translator's language maps, and the
      // existing convention (see the class itself) is that the Dart field
      // name and its string value match exactly — this is what
      // Translator.translate(AppStrings.xyz) actually looks up.
      expect(AppStrings.welcomeBack, 'welcomeBack');
      expect(AppStrings.loginButton, 'loginButton');
      expect(AppStrings.academyLevelLabel, 'academyLevelLabel');
      expect(AppStrings.masteryTierMastering, 'masteryTierMastering');
      expect(AppStrings.profileTitle, 'profileTitle');
    });
  });
}
