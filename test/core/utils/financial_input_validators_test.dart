import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/utils/financial_input_validators.dart';

void main() {
  group('FinancialInputValidators.parsePositiveDecimal', () {
    test('parses a plain integer string', () {
      expect(FinancialInputValidators.parsePositiveDecimal('100'), 100.0);
    });

    test('parses a decimal with a dot', () {
      expect(FinancialInputValidators.parsePositiveDecimal('35.5'), 35.5);
    });

    test('parses a decimal with a comma (pt-BR keyboards)', () {
      expect(FinancialInputValidators.parsePositiveDecimal('35,5'), 35.5);
    });

    test('trims surrounding whitespace', () {
      expect(FinancialInputValidators.parsePositiveDecimal('  10  '), 10.0);
    });

    test('rejects null', () {
      expect(FinancialInputValidators.parsePositiveDecimal(null), isNull);
    });

    test('rejects an empty string', () {
      expect(FinancialInputValidators.parsePositiveDecimal(''), isNull);
    });

    test('rejects a blank string', () {
      expect(FinancialInputValidators.parsePositiveDecimal('   '), isNull);
    });

    test('rejects non-numeric text', () {
      expect(FinancialInputValidators.parsePositiveDecimal('abc'), isNull);
    });

    test('rejects a value with trailing garbage', () {
      expect(FinancialInputValidators.parsePositiveDecimal('10abc'), isNull);
    });

    test('does NOT silently fall back to 0.0 for malformed input', () {
      expect(FinancialInputValidators.parsePositiveDecimal('abc'), isNot(0.0));
      expect(FinancialInputValidators.parsePositiveDecimal(''), isNot(0.0));
    });

    test('parses a negative number (rejection is the caller\'s job, this just parses)', () {
      expect(FinancialInputValidators.parsePositiveDecimal('-10'), -10.0);
    });

    test('rejects Infinity', () {
      expect(FinancialInputValidators.parsePositiveDecimal('Infinity'), isNull);
    });

    test('rejects NaN', () {
      expect(FinancialInputValidators.parsePositiveDecimal('NaN'), isNull);
    });
  });

  group('FinancialInputValidators.quantity', () {
    test('accepts a valid positive quantity', () {
      expect(FinancialInputValidators.quantity('100'), isNull);
    });

    test('accepts a fractional quantity (e.g. crypto)', () {
      expect(FinancialInputValidators.quantity('0.5'), isNull);
    });

    test('rejects blank input', () {
      expect(FinancialInputValidators.quantity(''), isNotNull);
    });

    test('rejects non-numeric text', () {
      expect(FinancialInputValidators.quantity('abc'), isNotNull);
    });

    test('rejects zero', () {
      expect(FinancialInputValidators.quantity('0'), isNotNull);
    });

    test('rejects a negative quantity', () {
      expect(FinancialInputValidators.quantity('-10'), isNotNull);
    });
  });

  group('FinancialInputValidators.price', () {
    test('accepts a valid positive price', () {
      expect(FinancialInputValidators.price('35.50'), isNull);
    });

    test('rejects blank input', () {
      expect(FinancialInputValidators.price(null), isNotNull);
    });

    test('rejects non-numeric text', () {
      expect(FinancialInputValidators.price('abc'), isNotNull);
    });

    test('rejects zero', () {
      expect(FinancialInputValidators.price('0'), isNotNull);
    });

    test('rejects a negative price', () {
      expect(FinancialInputValidators.price('-1'), isNotNull);
    });
  });
}
