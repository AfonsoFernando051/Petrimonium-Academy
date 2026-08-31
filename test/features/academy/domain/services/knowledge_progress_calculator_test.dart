import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/knowledge_level.dart';
import 'package:petrimonium/features/academy/domain/services/knowledge_progress_calculator.dart';

import '../../academy_test_fixtures.dart';

void main() {
  final catalog = buildAcademyCatalogSnapshot();

  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('overallCompletionPercent', () {
    test('is 0 when nothing is completed', () {
      expect(KnowledgeProgressCalculator.overallCompletionPercent(catalog, {}), 0);
    });

    test('is 1.0 when every lesson in every content-available module is completed', () {
      final allLessonIds = catalog.modules.where((m) => m.contentAvailable).expand((m) => m.lessonIds).toSet();

      expect(KnowledgeProgressCalculator.overallCompletionPercent(catalog, allLessonIds), 1.0);
    });

    test('ignores completed-lesson ids that belong to comingSoon/unavailable modules', () {
      // A random id that doesn't correspond to any real lesson shouldn't
      // inflate the denominator or numerator.
      final percentWithJunk = KnowledgeProgressCalculator.overallCompletionPercent(catalog, {'not-a-real-lesson-id'});
      expect(percentWithJunk, 0);
    });

    test('is strictly between 0 and 1 for a partial completion set', () {
      final firstModuleWithContent = catalog.modules.firstWhere((m) => m.contentAvailable && m.lessonIds.isNotEmpty);
      final partial = {firstModuleWithContent.lessonIds.first};

      final percent = KnowledgeProgressCalculator.overallCompletionPercent(catalog, partial);
      expect(percent, greaterThan(0));
      expect(percent, lessThan(1));
    });
  });

  group('percentForSchool', () {
    test('is 0 for an unknown school id (no matching modules)', () {
      expect(KnowledgeProgressCalculator.percentForSchool(catalog, 'does-not-exist', {}), 0);
    });

    test('is 1.0 when every lesson of that school\'s content-available modules is completed', () {
      final school = catalog.schools.firstWhere((s) => s.contentAvailable);
      final schoolLessonIds =
          catalog.modulesForSchool(school.id).where((m) => m.contentAvailable).expand((m) => m.lessonIds).toSet();

      expect(KnowledgeProgressCalculator.percentForSchool(catalog, school.id, schoolLessonIds), 1.0);
    });
  });

  group('levelForCompletion', () {
    test('0% maps to the first (absoluteBeginner) tier', () {
      expect(KnowledgeProgressCalculator.levelForCompletion(0.0), KnowledgeLevel.absoluteBeginner);
    });

    test('100% maps to the last (financialMaster) tier', () {
      expect(KnowledgeProgressCalculator.levelForCompletion(1.0), KnowledgeLevel.financialMaster);
    });

    test('clamps out-of-range percentages instead of throwing', () {
      expect(KnowledgeProgressCalculator.levelForCompletion(-0.5), KnowledgeLevel.absoluteBeginner);
      expect(KnowledgeProgressCalculator.levelForCompletion(1.5), KnowledgeLevel.financialMaster);
    });

    test('buckets into 10 equal-width tiers', () {
      expect(KnowledgeProgressCalculator.levelForCompletion(0.15), KnowledgeLevel.financialApprentice);
      expect(KnowledgeProgressCalculator.levelForCompletion(0.55), KnowledgeLevel.investor);
      expect(KnowledgeProgressCalculator.levelForCompletion(0.95), KnowledgeLevel.financialMaster);
    });
  });

  group('labelFor', () {
    test('returns a non-empty, language-aware label for every tier', () {
      for (final level in KnowledgeLevel.values) {
        expect(KnowledgeProgressCalculator.labelFor(level), isNotEmpty);
      }
    });

    test('follows the active Translator language', () {
      Translator.currentLanguage = 'en';
      expect(KnowledgeProgressCalculator.labelFor(KnowledgeLevel.absoluteBeginner), 'Absolute Beginner');
    });
  });
}
