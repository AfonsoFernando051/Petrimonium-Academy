import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';
import 'package:petrimonium/features/academy/domain/services/mastery_calculator.dart';

import '../../academy_test_fixtures.dart';

void main() {
  final catalog = buildAcademyCatalogSnapshot();
  final school = testSchool;
  final lessons = catalog.lessonsForModule(testModule.id);

  group('lessonMasteryScore', () {
    test('not completed scores 0.0 regardless of perfect flag', () {
      expect(MasteryCalculator.lessonMasteryScore(completed: false, perfect: false), 0.0);
      expect(MasteryCalculator.lessonMasteryScore(completed: false, perfect: true), 0.0);
    });

    test('completed but not perfect scores partial credit', () {
      final score = MasteryCalculator.lessonMasteryScore(completed: true, perfect: false);
      expect(score, greaterThan(0.0));
      expect(score, lessThan(1.0));
    });

    test('completed and perfect scores full credit', () {
      expect(MasteryCalculator.lessonMasteryScore(completed: true, perfect: true), 1.0);
    });
  });

  group('percentForSchool', () {
    test('nothing completed scores 0%', () {
      final percent = MasteryCalculator.percentForSchool(
        catalog: catalog,
        schoolId: school.id,
        completedIds: {},
        perfectIds: {},
      );
      expect(percent, 0.0);
    });

    test('all lessons completed perfectly scores 100%', () {
      final allLessonIds =
          catalog.modulesForSchool(school.id).where((m) => m.contentAvailable).expand((m) => m.lessonIds).toSet();
      final percent = MasteryCalculator.percentForSchool(
        catalog: catalog,
        schoolId: school.id,
        completedIds: allLessonIds,
        perfectIds: allLessonIds,
      );
      expect(percent, 1.0);
    });

    test('a completed-but-imperfect lesson scores less than a completed-and-perfect one', () {
      final perfectOnly = MasteryCalculator.percentForSchool(
        catalog: catalog,
        schoolId: school.id,
        completedIds: {lessons.first.id},
        perfectIds: {lessons.first.id},
      );
      final imperfectOnly = MasteryCalculator.percentForSchool(
        catalog: catalog,
        schoolId: school.id,
        completedIds: {lessons.first.id},
        perfectIds: {},
      );
      expect(imperfectOnly, lessThan(perfectOnly));
      expect(imperfectOnly, greaterThan(0.0));
    });

    test('progress (completion) and mastery can diverge for the same state', () {
      // Completing every lesson without ever answering perfectly should read
      // as 100% complete but well below 100% mastery — the exact scenario
      // the brief (and DECISION-020) call out explicitly.
      final allLessonIds =
          catalog.modulesForSchool(school.id).where((m) => m.contentAvailable).expand((m) => m.lessonIds).toSet();
      final mastery = MasteryCalculator.percentForSchool(
        catalog: catalog,
        schoolId: school.id,
        completedIds: allLessonIds,
        perfectIds: {},
      );
      expect(mastery, lessThan(1.0));
      expect(mastery, greaterThan(0.0));
    });
  });

  group('tierForPercent', () {
    test('buckets into the 4 tiers by threshold', () {
      expect(MasteryCalculator.tierForPercent(0.0), MasteryTier.exploring);
      expect(MasteryCalculator.tierForPercent(0.24), MasteryTier.exploring);
      expect(MasteryCalculator.tierForPercent(0.25), MasteryTier.understanding);
      expect(MasteryCalculator.tierForPercent(0.59), MasteryTier.understanding);
      expect(MasteryCalculator.tierForPercent(0.60), MasteryTier.applying);
      expect(MasteryCalculator.tierForPercent(0.84), MasteryTier.applying);
      expect(MasteryCalculator.tierForPercent(0.85), MasteryTier.mastering);
      expect(MasteryCalculator.tierForPercent(1.0), MasteryTier.mastering);
    });

    test('clamps out-of-range input', () {
      expect(MasteryCalculator.tierForPercent(-1.0), MasteryTier.exploring);
      expect(MasteryCalculator.tierForPercent(2.0), MasteryTier.mastering);
    });
  });
}
