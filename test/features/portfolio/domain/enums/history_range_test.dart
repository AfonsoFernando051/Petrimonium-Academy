import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';

void main() {
  group('HistoryRange', () {
    test('each value has the expected apiValue and label', () {
      expect(HistoryRange.d7.apiValue, '7D');
      expect(HistoryRange.d7.label, '7D');

      expect(HistoryRange.d30.apiValue, '30D');
      expect(HistoryRange.d30.label, '30D');

      expect(HistoryRange.m3.apiValue, '3M');
      expect(HistoryRange.m3.label, '3M');

      expect(HistoryRange.m6.apiValue, '6M');
      expect(HistoryRange.m6.label, '6M');

      expect(HistoryRange.y1.apiValue, '1Y');
      expect(HistoryRange.y1.label, '1A');

      expect(HistoryRange.y3.apiValue, '3Y');
      expect(HistoryRange.y3.label, '3A');

      expect(HistoryRange.y5.apiValue, '5Y');
      expect(HistoryRange.y5.label, '5A');

      expect(HistoryRange.all.apiValue, 'ALL');
      expect(HistoryRange.all.label, 'Tudo');
    });

    test('has exactly 8 values in declaration order', () {
      expect(HistoryRange.values, [
        HistoryRange.d7,
        HistoryRange.d30,
        HistoryRange.m3,
        HistoryRange.m6,
        HistoryRange.y1,
        HistoryRange.y3,
        HistoryRange.y5,
        HistoryRange.all,
      ]);
    });
  });
}
