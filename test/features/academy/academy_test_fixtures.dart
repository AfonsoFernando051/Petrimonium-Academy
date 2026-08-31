import 'package:flutter/material.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_domain.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';

/// A small but structurally realistic [AcademyCatalogSnapshot] for tests
/// that used to exercise the real (now-deleted) hardcoded `AcademyCatalog`:
/// one domain, one school with real content plus one `comingSoon`
/// placeholder school, one content-available module with 3 lessons (one of
/// each interactive step type), so the progression/mastery/recommendation
/// rules under test have real sequencing (lesson order, module/school
/// content-availability) to exercise.
AcademyCatalogSnapshot buildAcademyCatalogSnapshot() {
  return const AcademyCatalogSnapshot(
    domains: [testDomain],
    schools: [testSchool, testComingSoonSchool],
    modules: [testModule],
    lessons: [testLesson1, testLesson2, testLesson3],
  );
}

const testDomain = AcademyDomain(
  id: 'test_domain',
  title: 'Test Domain',
  description: 'desc',
  icon: Icons.school,
  order: 1,
  schoolIds: ['test_school', 'test_coming_soon_school'],
);

const testSchool = School(
  id: 'test_school',
  title: 'Test School',
  description: 'desc',
  icon: Icons.school,
  order: 1,
  contentAvailable: true,
);

const testComingSoonSchool = School(
  id: 'test_coming_soon_school',
  title: 'Coming Soon School',
  description: 'desc',
  icon: Icons.school,
  order: 2,
  contentAvailable: false,
);

const testModule = AcademyModule(
  id: 'test_module',
  schoolId: 'test_school',
  title: 'Test Module',
  description: 'desc',
  icon: Icons.school,
  order: 1,
  lessonIds: ['test_lesson_1', 'test_lesson_2', 'test_lesson_3'],
  contentAvailable: true,
);

const testLesson1 = Lesson(
  id: 'test_lesson_1',
  moduleId: 'test_module',
  title: 'Lesson 1',
  order: 1,
  xpReward: 20,
  steps: [ExplanationStep(title: 'Explain', body: 'Body')],
);

const testLesson2 = Lesson(
  id: 'test_lesson_2',
  moduleId: 'test_module',
  title: 'Lesson 2',
  order: 2,
  xpReward: 20,
  steps: [
    ChoiceQuestionStep(
      framing: ChoiceStepFraming.microExercise,
      prompt: 'Prompt?',
      options: ['A', 'B'],
      correctIndex: 0,
      explanation: 'Explanation',
    ),
  ],
);

const testLesson3 = Lesson(
  id: 'test_lesson_3',
  moduleId: 'test_module',
  title: 'Lesson 3',
  order: 3,
  xpReward: 20,
  steps: [SummaryStep(title: 'Summary', takeaways: ['Takeaway'])],
);
