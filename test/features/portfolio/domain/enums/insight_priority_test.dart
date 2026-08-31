import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/enums/insight_priority.dart';

void main() {
  group('InsightPriority', () {
    test('has exactly the three expected values in declaration order', () {
      expect(InsightPriority.values, [
        InsightPriority.high,
        InsightPriority.medium,
        InsightPriority.low,
      ]);
    });
  });
}
