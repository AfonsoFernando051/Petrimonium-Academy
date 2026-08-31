import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/onboarding/data/models/option_model.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';

void main() {
  group('QuestionModel.fromJson', () {
    test('parses id, text, and nested options list', () {
      final question = QuestionModel.fromJson(const {
        'id': 'q1',
        'text': 'Qual seu objetivo?',
        'options': [
          {'id': 'q1_a', 'text': 'Crescer patrimônio'},
          {'id': 'q1_b', 'text': 'Renda passiva'},
        ],
      });

      expect(question.id, 'q1');
      expect(question.text, 'Qual seu objetivo?');
      expect(question.options, hasLength(2));
      expect(question.options[0].id, 'q1_a');
      expect(question.options[0].text, 'Crescer patrimônio');
      expect(question.options[1].id, 'q1_b');
    });

    test('parses an empty options list', () {
      final question = QuestionModel.fromJson(const {
        'id': 'q2',
        'text': 'Empty',
        'options': <Map<String, dynamic>>[],
      });

      expect(question.options, isEmpty);
    });
  });

  test('const constructor sets fields directly', () {
    const question = QuestionModel(
      id: 'q3',
      text: 'Text',
      options: [OptionModel(id: 'a', text: 'A')],
    );

    expect(question.id, 'q3');
    expect(question.options, hasLength(1));
  });
}
