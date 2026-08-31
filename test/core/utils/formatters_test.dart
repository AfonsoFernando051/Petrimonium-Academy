import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/utils/formatters.dart';

void main() {
  group('AppFormatters.currency', () {
    test('formats a positive value with cents and thousands separator', () {
      expect(AppFormatters.currency(15200.5), 'R\$ 15.200,50');
    });

    test('formats a negative value with a leading minus sign', () {
      expect(AppFormatters.currency(-1234.56), '-R\$ 1.234,56');
    });

    test('omits cents when showCents is false', () {
      expect(AppFormatters.currency(1500, showCents: false), 'R\$ 1.500');
    });

    test('formats zero', () {
      expect(AppFormatters.currency(0), 'R\$ 0,00');
    });

    test('formats a small value without thousands separator', () {
      expect(AppFormatters.currency(9.99), 'R\$ 9,99');
    });
  });

  group('AppFormatters.compactCurrency', () {
    test('formats millions with an M suffix', () {
      expect(AppFormatters.compactCurrency(2500000), 'R\$ 2.5M');
    });

    test('formats thousands with a K suffix', () {
      expect(AppFormatters.compactCurrency(15200), 'R\$ 15.2K');
    });

    test('falls back to plain currency below one thousand', () {
      expect(AppFormatters.compactCurrency(500), 'R\$ 500');
    });

    test('handles negative values with the sign before R\$', () {
      expect(AppFormatters.compactCurrency(-2500000), '-R\$ 2.5M');
    });
  });

  group('AppFormatters.percent', () {
    test('prefixes a positive value with a plus sign by default', () {
      expect(AppFormatters.percent(4.256), '+4.26%');
    });

    test('does not prefix a negative value', () {
      expect(AppFormatters.percent(-4.256), '-4.26%');
    });

    test('omits the sign when showSign is false', () {
      expect(AppFormatters.percent(4.256, showSign: false), '4.26%');
    });

    test('does not prefix zero', () {
      expect(AppFormatters.percent(0), '0.00%');
    });
  });

  group('AppFormatters.percentPlain', () {
    test('formats with one decimal by default and no sign', () {
      expect(AppFormatters.percentPlain(8), '8.0%');
    });

    test('respects a custom decimals count', () {
      expect(AppFormatters.percentPlain(5.256, decimals: 2), '5.26%');
    });

    test('never prefixes a positive value with a plus sign', () {
      expect(AppFormatters.percentPlain(4.2), '4.2%');
    });
  });

  group('AppFormatters.multiplier', () {
    test('formats with a comma decimal and trailing x', () {
      expect(AppFormatters.multiplier(2.4), '2,4x');
    });

    test('formats a whole number', () {
      expect(AppFormatters.multiplier(3), '3,0x');
    });
  });

  group('AppFormatters.date', () {
    test('formats as dd/mm/yyyy with zero-padding', () {
      expect(AppFormatters.date(DateTime(2024, 3, 5)), '05/03/2024');
    });
  });

  group('AppFormatters.shortDate', () {
    test('formats as dd/mm with zero-padding', () {
      expect(AppFormatters.shortDate(DateTime(2024, 3, 5)), '05/03');
    });
  });
}
