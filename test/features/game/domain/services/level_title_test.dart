import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/game/domain/services/level_title.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('LevelTitle.forLevel', () {
    test('below 5 is Beginner', () {
      expect(LevelTitle.forLevel(1), 'Iniciante');
      expect(LevelTitle.forLevel(4), 'Iniciante');
    });

    test('5 up to (not including) 10 is Learner', () {
      expect(LevelTitle.forLevel(5), 'Aprendiz');
      expect(LevelTitle.forLevel(9), 'Aprendiz');
    });

    test('10 up to (not including) 15 is Explorer', () {
      expect(LevelTitle.forLevel(10), 'Explorador');
      expect(LevelTitle.forLevel(14), 'Explorador');
    });

    test('15 up to (not including) 20 is Investor', () {
      expect(LevelTitle.forLevel(15), 'Investidor');
      expect(LevelTitle.forLevel(19), 'Investidor');
    });

    test('20 up to (not including) 30 is Analyst', () {
      expect(LevelTitle.forLevel(20), 'Analista');
      expect(LevelTitle.forLevel(29), 'Analista');
    });

    test('30 up to (not including) 40 is Strategist', () {
      expect(LevelTitle.forLevel(30), 'Estrategista');
      expect(LevelTitle.forLevel(39), 'Estrategista');
    });

    test('40 and above is Specialist', () {
      expect(LevelTitle.forLevel(40), 'Especialista');
      expect(LevelTitle.forLevel(100), 'Especialista');
    });

    test('follows the active Translator language', () {
      Translator.currentLanguage = 'en';
      expect(LevelTitle.forLevel(1), 'Beginner');
      Translator.currentLanguage = 'es';
      expect(LevelTitle.forLevel(1), 'Principiante');
    });
  });
}
