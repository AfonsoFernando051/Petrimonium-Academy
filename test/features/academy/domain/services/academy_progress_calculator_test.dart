import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_domain.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';

import '../../academy_test_fixtures.dart';

void main() {
  final catalog = buildAcademyCatalogSnapshot();
  final contentModule = testModule;
  final moduleLessons = catalog.lessonsForModule(contentModule.id);

  group('lessonStatus', () {
    test('the first lesson of a module is always available when nothing is completed', () {
      final status = AcademyProgressCalculator.lessonStatus(catalog: catalog, lesson: moduleLessons.first, completedIds: {});
      expect(status, LessonStatus.available);
    });

    test('a completed lesson is completed regardless of position', () {
      final status = AcademyProgressCalculator.lessonStatus(
        catalog: catalog,
        lesson: moduleLessons.first,
        completedIds: {moduleLessons.first.id},
      );
      expect(status, LessonStatus.completed);
    });

    test('the second lesson is locked until the first is completed', () {
      final second = moduleLessons[1];
      final locked = AcademyProgressCalculator.lessonStatus(catalog: catalog, lesson: second, completedIds: {});
      expect(locked, LessonStatus.locked);

      final unlocked = AcademyProgressCalculator.lessonStatus(
        catalog: catalog,
        lesson: second,
        completedIds: {moduleLessons.first.id},
      );
      expect(unlocked, LessonStatus.available);
    });
  });

  group('moduleStatus', () {
    test('a module with no real content is comingSoon', () {
      const placeholder = AcademyModule(
        id: 'placeholder',
        schoolId: 'x',
        title: 'x',
        description: 'x',
        icon: Icons.school,
        order: 1,
        contentAvailable: false,
      );
      expect(
        AcademyProgressCalculator.moduleStatus(catalog: catalog, module: placeholder, completedIds: {}),
        ModuleStatus.comingSoon,
      );
    });

    test('an unmet prerequisite locks the module even if it has content', () {
      final gated = AcademyModule(
        id: 'gated',
        schoolId: contentModule.schoolId,
        title: 'x',
        description: 'x',
        icon: Icons.school,
        order: 1,
        lessonIds: contentModule.lessonIds,
        prerequisites: const ['some-unmet-prereq'],
        contentAvailable: true,
      );
      expect(
        AcademyProgressCalculator.moduleStatus(catalog: catalog, module: gated, completedIds: {}),
        ModuleStatus.locked,
      );
    });

    test('a prerequisite is satisfied once every lesson of the prerequisite module is completed '
        '(regression: prerequisite ids are module ids, not lesson ids — must not be checked '
        'against completedIds directly, or the module could never unlock)', () {
      final gated = AcademyModule(
        id: 'gated-real',
        schoolId: contentModule.schoolId,
        title: 'x',
        description: 'x',
        icon: Icons.school,
        order: 2,
        lessonIds: contentModule.lessonIds,
        prerequisites: [contentModule.id],
        contentAvailable: true,
      );
      final allPrereqLessons = moduleLessons.map((l) => l.id).toSet();

      expect(
        AcademyProgressCalculator.moduleStatus(catalog: catalog, module: gated, completedIds: {}),
        ModuleStatus.locked,
        reason: 'prerequisite module not yet completed',
      );
      expect(
        AcademyProgressCalculator.moduleStatus(catalog: catalog, module: gated, completedIds: allPrereqLessons),
        isNot(ModuleStatus.locked),
        reason: 'every lesson of the prerequisite module is now completed, so it must unlock',
      );
    });

    test('available with zero completed lessons, inProgress partway, completed when all done', () {
      expect(
        AcademyProgressCalculator.moduleStatus(catalog: catalog, module: contentModule, completedIds: {}),
        ModuleStatus.available,
      );

      final partial = {moduleLessons.first.id};
      expect(
        AcademyProgressCalculator.moduleStatus(catalog: catalog, module: contentModule, completedIds: partial),
        ModuleStatus.inProgress,
      );

      final all = moduleLessons.map((l) => l.id).toSet();
      expect(
        AcademyProgressCalculator.moduleStatus(catalog: catalog, module: contentModule, completedIds: all),
        ModuleStatus.completed,
      );
    });

    test('missingModulePrerequisiteTitles is empty once unlocked, and names the missing module before that', () {
      final gated = AcademyModule(
        id: 'gated-titled',
        schoolId: contentModule.schoolId,
        title: 'x',
        description: 'x',
        icon: Icons.school,
        order: 3,
        lessonIds: contentModule.lessonIds,
        prerequisites: [contentModule.id],
        contentAvailable: true,
      );

      expect(
        AcademyProgressCalculator.missingModulePrerequisiteTitles(catalog: catalog, module: gated, completedIds: {}),
        [contentModule.title],
      );

      final all = moduleLessons.map((l) => l.id).toSet();
      expect(
        AcademyProgressCalculator.missingModulePrerequisiteTitles(catalog: catalog, module: gated, completedIds: all),
        isEmpty,
      );
    });
  });

  group('schoolStatus', () {
    test('a school with no content-available modules is comingSoon', () {
      const emptySchool = School(id: 'empty', title: 'x', description: 'x', icon: Icons.school, order: 1, contentAvailable: false);
      expect(AcademyProgressCalculator.schoolStatus(catalog: catalog, school: emptySchool, completedIds: {}), SchoolStatus.comingSoon);
    });

    test('an unmet school-level prerequisite locks it', () {
      final gated = School(
        id: 'gated-school',
        title: 'x',
        description: 'x',
        icon: Icons.school,
        order: 1,
        prerequisites: const ['some-unmet-prereq'],
        contentAvailable: true,
      );
      expect(AcademyProgressCalculator.schoolStatus(catalog: catalog, school: gated, completedIds: {}), SchoolStatus.locked);
    });

    test('a real available school with content resolves to a real status (not comingSoon/locked)', () {
      final school = catalog.schools.firstWhere((s) => s.contentAvailable && s.prerequisites.isEmpty);
      final status = AcademyProgressCalculator.schoolStatus(catalog: catalog, school: school, completedIds: {});
      expect(status, anyOf(SchoolStatus.available, SchoolStatus.inProgress, SchoolStatus.completed));
    });

    test('a prerequisite is satisfied once every module of the prerequisite school is completed '
        '(regression: prerequisite ids are school ids, not lesson ids — must not be checked '
        'against completedIds directly, or the school could never unlock)', () {
      final gated = School(
        id: 'gated-school-real',
        title: 'x',
        description: 'x',
        icon: Icons.school,
        order: 2,
        prerequisites: const ['test_school'],
        contentAvailable: true,
      );
      final allPrereqLessons = moduleLessons.map((l) => l.id).toSet();

      expect(
        AcademyProgressCalculator.schoolStatus(catalog: catalog, school: gated, completedIds: {}),
        SchoolStatus.locked,
        reason: 'prerequisite school not yet completed',
      );
      expect(
        AcademyProgressCalculator.schoolStatus(catalog: catalog, school: gated, completedIds: allPrereqLessons),
        isNot(SchoolStatus.locked),
        reason: 'every module of the prerequisite school is now completed, so it must unlock',
      );
    });

    test('missingSchoolPrerequisiteTitles is empty once unlocked, and names the missing school before that', () {
      final gated = School(
        id: 'gated-school-titled',
        title: 'x',
        description: 'x',
        icon: Icons.school,
        order: 3,
        prerequisites: const ['test_school'],
        contentAvailable: true,
      );

      expect(
        AcademyProgressCalculator.missingSchoolPrerequisiteTitles(catalog: catalog, school: gated, completedIds: {}),
        [testSchool.title],
      );

      final all = moduleLessons.map((l) => l.id).toSet();
      expect(
        AcademyProgressCalculator.missingSchoolPrerequisiteTitles(catalog: catalog, school: gated, completedIds: all),
        isEmpty,
      );
    });
  });

  group('domainStatus', () {
    test('a domain with no schools is comingSoon', () {
      const empty = AcademyDomain(id: 'empty', title: 'x', description: 'x', icon: Icons.school, order: 1);
      expect(AcademyProgressCalculator.domainStatus(catalog: catalog, domain: empty, completedIds: {}), SchoolStatus.comingSoon);
    });

    test('a domain whose only school has no content-available modules is comingSoon', () {
      final placeholderOnly = AcademyDomain(
        id: 'placeholder-domain',
        title: 'x',
        description: 'x',
        icon: Icons.school,
        order: 1,
        schoolIds: [catalog.schools.firstWhere((s) => !s.contentAvailable).id],
      );
      expect(
        AcademyProgressCalculator.domainStatus(catalog: catalog, domain: placeholderOnly, completedIds: {}),
        SchoolStatus.comingSoon,
      );
    });

    test('a domain whose school has real content resolves to a real status (not comingSoon/locked)', () {
      final status = AcademyProgressCalculator.domainStatus(catalog: catalog, domain: testDomain, completedIds: {});
      expect(status, anyOf(SchoolStatus.available, SchoolStatus.inProgress, SchoolStatus.completed));
    });
  });

  group('nextLessonToContinue', () {
    test('returns the first lesson of the curriculum when nothing is completed', () {
      final next = AcademyProgressCalculator.nextLessonToContinue(catalog: catalog, completedIds: {});
      expect(next, isNotNull);
    });

    test('returns null once every available lesson is completed', () {
      final allAvailableLessonIds = catalog.modules.where((m) => m.contentAvailable).expand((m) => m.lessonIds).toSet();

      final next = AcademyProgressCalculator.nextLessonToContinue(catalog: catalog, completedIds: allAvailableLessonIds);
      expect(next, isNull);
    });

    test('skips a completed lesson and returns the next incomplete one in the same module', () {
      final next = AcademyProgressCalculator.nextLessonToContinue(catalog: catalog, completedIds: {moduleLessons.first.id});
      expect(next, isNot(equals(moduleLessons.first)));
    });
  });
}
