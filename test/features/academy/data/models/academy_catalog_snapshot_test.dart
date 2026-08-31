import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

Map<String, dynamic> _fixtureJson() => {
      'domains': [
        {
          'id': 'financial_education',
          'title': 'Educação Financeira',
          'description': 'desc',
          'iconKey': 'savings_outlined',
          'order': 1,
          'schoolIds': ['financial_life'],
        },
      ],
      'schools': [
        {
          'id': 'financial_life',
          'domainId': 'financial_education',
          'title': 'Vida Financeira',
          'description': 'desc',
          'iconKey': 'account_balance_wallet_outlined',
          'order': 1,
          'prerequisites': <String>[],
          'contentAvailable': true,
        },
      ],
      'modules': [
        {
          'id': 'money_fundamentals',
          'schoolId': 'financial_life',
          'title': 'Fundamentos do Dinheiro',
          'description': 'desc',
          'iconKey': 'payments_outlined',
          'order': 1,
          'lessonIds': ['money_fundamentals_what_is_money'],
          'prerequisites': <String>[],
          'contentAvailable': true,
        },
      ],
      'lessons': [
        {
          'id': 'money_fundamentals_what_is_money',
          'moduleId': 'money_fundamentals',
          'title': 'O que é Dinheiro?',
          'order': 1,
          'xpReward': 20,
          'steps': [
            {'type': 'explanation', 'title': 'Título', 'body': 'Corpo'},
            {'type': 'example', 'title': 'Exemplo', 'body': 'Corpo do exemplo'},
            {
              'type': 'choice_question',
              'framing': 'micro_exercise',
              'prompt': 'Pergunta?',
              'options': ['A', 'B', 'C'],
              'correctIndex': 1,
              'explanation': 'Porque sim.',
            },
            {
              'type': 'choice_question',
              'framing': 'apply',
              'prompt': 'Aplique isso',
              'options': ['X', 'Y'],
              'correctIndex': 0,
              'explanation': 'Explicação.',
            },
            {
              'type': 'summary',
              'title': 'Resumo',
              'takeaways': ['Ponto 1', 'Ponto 2'],
            },
          ],
        },
      ],
    };

void main() {
  group('AcademyCatalogSnapshot.fromJson', () {
    late AcademyCatalogSnapshot snapshot;

    setUp(() {
      snapshot = AcademyCatalogSnapshot.fromJson(_fixtureJson());
    });

    test('parses domains, schools, modules and lessons with resolved icons', () {
      expect(snapshot.domains, hasLength(1));
      expect(snapshot.domains.first.icon, Icons.savings_outlined);
      expect(snapshot.schools.first.icon, Icons.account_balance_wallet_outlined);
      expect(snapshot.modules.first.icon, Icons.payments_outlined);
    });

    test('falls back to a default icon for an unknown iconKey', () {
      final json = _fixtureJson();
      (json['domains'] as List)[0]['iconKey'] = 'totally_unknown_icon';

      final result = AcademyCatalogSnapshot.fromJson(json);

      expect(result.domains.first.icon, Icons.help_outline);
    });

    test('parses every lesson step type with its type-specific fields', () {
      final lesson = snapshot.lessons.single;
      expect(lesson.steps, hasLength(5));

      final explanation = lesson.steps[0] as ExplanationStep;
      expect(explanation.title, 'Título');
      expect(explanation.body, 'Corpo');

      final example = lesson.steps[1] as ExampleStep;
      expect(example.body, 'Corpo do exemplo');

      final microExercise = lesson.steps[2] as ChoiceQuestionStep;
      expect(microExercise.framing, ChoiceStepFraming.microExercise);
      expect(microExercise.options, ['A', 'B', 'C']);
      expect(microExercise.correctIndex, 1);

      final apply = lesson.steps[3] as ChoiceQuestionStep;
      expect(apply.framing, ChoiceStepFraming.apply);

      final summary = lesson.steps[4] as SummaryStep;
      expect(summary.takeaways, ['Ponto 1', 'Ponto 2']);
    });

    test('lookup helpers mirror the old static AcademyCatalog API', () {
      expect(snapshot.schoolById('financial_life')?.title, 'Vida Financeira');
      expect(snapshot.moduleById('money_fundamentals')?.title, 'Fundamentos do Dinheiro');
      expect(snapshot.domainForSchool('financial_life')?.id, 'financial_education');
      expect(snapshot.modulesForSchool('financial_life'), hasLength(1));
      expect(snapshot.lessonsForModule('money_fundamentals'), hasLength(1));
      expect(snapshot.xpEarnedFor({'money_fundamentals_what_is_money'}), 20);
      expect(snapshot.xpEarnedFor({}), 0);
    });

    test('toJson/fromJson round-trips to an equivalent snapshot', () {
      final roundTripped = AcademyCatalogSnapshot.fromJson(snapshot.toJson());

      expect(roundTripped.domains.first.id, snapshot.domains.first.id);
      expect(roundTripped.lessons.first.steps.length, snapshot.lessons.first.steps.length);
      expect((roundTripped.lessons.first.steps[2] as ChoiceQuestionStep).options,
          (snapshot.lessons.first.steps[2] as ChoiceQuestionStep).options);
    });

    test('a lesson with no portfolioConcepts field (old cache / most lessons) defaults to empty', () {
      // The fixture's lesson JSON has no 'portfolioConcepts' key at all — this is the real
      // shape of most lessons today, and of every cache entry written before this field
      // existed, so this must never throw or default to null.
      expect(snapshot.lessons.single.portfolioConcepts, isEmpty);
    });

    test('portfolioConcepts round-trips through toJson/fromJson when present', () {
      final json = _fixtureJson();
      (json['lessons'] as List)[0]['portfolioConcepts'] = ['pe', 'pvp'];

      final withConcepts = AcademyCatalogSnapshot.fromJson(json);
      expect(withConcepts.lessons.single.portfolioConcepts, ['pe', 'pvp']);

      final roundTripped = AcademyCatalogSnapshot.fromJson(withConcepts.toJson());
      expect(roundTripped.lessons.single.portfolioConcepts, ['pe', 'pvp']);
    });
  });
}
