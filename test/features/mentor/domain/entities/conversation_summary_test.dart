import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/mentor/domain/entities/conversation_summary.dart';

void main() {
  group('ConversationSummary.fromJson', () {
    test('parses every field including lastMessagePreview', () {
      final summary = ConversationSummary.fromJson({
        'id': 7,
        'title': 'Dúvidas sobre Renda Fixa',
        'updatedAt': '2024-05-01T12:00:00.000',
        'lastMessagePreview': 'Obrigado pela ajuda!',
      });

      expect(summary.id, 7);
      expect(summary.title, 'Dúvidas sobre Renda Fixa');
      expect(summary.updatedAt, DateTime.parse('2024-05-01T12:00:00.000'));
      expect(summary.lastMessagePreview, 'Obrigado pela ajuda!');
    });

    test('lastMessagePreview is null when absent', () {
      final summary = ConversationSummary.fromJson({
        'id': 1,
        'title': 'Chat',
        'updatedAt': '2024-01-01T00:00:00.000',
      });

      expect(summary.lastMessagePreview, isNull);
    });

    test('title defaults to empty string when missing', () {
      final summary = ConversationSummary.fromJson({
        'id': 1,
        'updatedAt': '2024-01-01T00:00:00.000',
      });

      expect(summary.title, '');
    });

    test('updatedAt falls back to now() for an unparseable/missing value', () {
      final before = DateTime.now();
      final summary = ConversationSummary.fromJson({'id': 1, 'title': 'Chat'});
      final after = DateTime.now();

      expect(summary.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(summary.updatedAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  test('const constructor sets fields directly', () {
    final updatedAt = DateTime(2024, 1, 1);
    final summary = ConversationSummary(id: 5, title: 'T', updatedAt: updatedAt);

    expect(summary.id, 5);
    expect(summary.title, 'T');
    expect(summary.updatedAt, updatedAt);
    expect(summary.lastMessagePreview, isNull);
  });
}
