import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/knowledge_level.dart';

void main() {
  group('KnowledgeLevel', () {
    test('has exactly the 10 expected tiers, in order', () {
      expect(KnowledgeLevel.values, [
        KnowledgeLevel.absoluteBeginner,
        KnowledgeLevel.financialApprentice,
        KnowledgeLevel.financialOrganizer,
        KnowledgeLevel.financialProtector,
        KnowledgeLevel.beginnerInvestor,
        KnowledgeLevel.investor,
        KnowledgeLevel.analyst,
        KnowledgeLevel.wealthBuilder,
        KnowledgeLevel.financialStrategist,
        KnowledgeLevel.financialMaster,
      ]);
    });
  });
}
