import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/asset_details/domain/entities/educational_explanation.dart';

void main() {
  group('EducationalExplanation', () {
    test('constructs with the given fields', () {
      const explanation = EducationalExplanation(
        indicatorId: 'pe',
        title: 'P/E Ratio',
        definition: 'Price divided by earnings.',
        whyItMatters: 'Shows how expensive a stock is relative to profit.',
        caveat: 'Should be compared within the same sector.',
        petDialogue: 'Woof! Lower is usually cheaper.',
      );

      expect(explanation.indicatorId, 'pe');
      expect(explanation.title, 'P/E Ratio');
      expect(explanation.definition, 'Price divided by earnings.');
      expect(explanation.whyItMatters, 'Shows how expensive a stock is relative to profit.');
      expect(explanation.caveat, 'Should be compared within the same sector.');
      expect(explanation.petDialogue, 'Woof! Lower is usually cheaper.');
    });

    test('petDialogue is optional', () {
      const explanation = EducationalExplanation(
        indicatorId: 'pe',
        title: 'P/E Ratio',
        definition: 'd',
        whyItMatters: 'w',
        caveat: 'c',
      );

      expect(explanation.petDialogue, isNull);
    });
  });
}
