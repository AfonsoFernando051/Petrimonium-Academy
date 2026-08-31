import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/utils/translator.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('Translator', () {
    test('translates key to Portuguese by default', () {
      expect(Translator.translate(AppStrings.welcomeBack), "Bem-vindo de volta");
    });

    test('translates key to English when language changes', () {
      Translator.currentLanguage = 'en';
      expect(Translator.translate(AppStrings.welcomeBack), "Welcome back");
    });

    test('translates key to Spanish when language changes', () {
      Translator.currentLanguage = 'es';
      expect(Translator.translate(AppStrings.welcomeBack), "Bienvenido de nuevo");
    });

    test('falls back to default language if language is unsupported', () {
      Translator.currentLanguage = 'fr';
      expect(Translator.translate(AppStrings.welcomeBack), "Bem-vindo de volta");
    });

    test('returns key itself if translation for key is missing', () {
      expect(Translator.translate('unknownKey'), 'unknownKey');
    });
  });

  // A missing en/es key silently falls back to pt via `translate()` — no
  // exception, no visible sign anything is wrong. These guard against that:
  // a language block drifting out of parity is caught here, not by a user
  // spotting Portuguese text in the English app.
  group('Translator — language parity', () {
    test('en defines exactly the same key set as pt', () {
      final values = Translator.debugLocalizedValues;
      final ptKeys = values['pt']!.keys.toSet();
      final enKeys = values['en']!.keys.toSet();
      expect(
        enKeys.difference(ptKeys),
        isEmpty,
        reason: 'en has keys pt does not define',
      );
      expect(
        ptKeys.difference(enKeys),
        isEmpty,
        reason: 'en is missing keys pt defines',
      );
    });

    test('es defines exactly the same key set as pt', () {
      final values = Translator.debugLocalizedValues;
      final ptKeys = values['pt']!.keys.toSet();
      final esKeys = values['es']!.keys.toSet();
      expect(
        esKeys.difference(ptKeys),
        isEmpty,
        reason: 'es has keys pt does not define',
      );
      expect(
        ptKeys.difference(esKeys),
        isEmpty,
        reason: 'es is missing keys pt defines',
      );
    });

    test('no translation value is left as an untranslated copy of its key', () {
      final offenders = <String>[];
      for (final entry in Translator.debugLocalizedValues.entries) {
        for (final kv in entry.value.entries) {
          if (kv.value == kv.key) offenders.add('${entry.key}.${kv.key}');
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'these entries were never actually translated: $offenders',
      );
    });
  });
}
