import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('defaults isError to false', () {
      final message = ChatMessage(
        id: '1',
        role: ChatRole.user,
        text: 'Hello',
        timestamp: DateTime(2024, 1, 1),
      );

      expect(message.isError, isFalse);
    });

    group('copyWith', () {
      test('overrides text and isError while keeping id/role/timestamp', () {
        final timestamp = DateTime(2024, 1, 1);
        final original = ChatMessage(id: '1', role: ChatRole.mentor, text: 'old', timestamp: timestamp);

        final updated = original.copyWith(text: 'new', isError: true);

        expect(updated.id, '1');
        expect(updated.role, ChatRole.mentor);
        expect(updated.timestamp, timestamp);
        expect(updated.text, 'new');
        expect(updated.isError, isTrue);
      });

      test('with no args keeps every field unchanged', () {
        final timestamp = DateTime(2024, 1, 1);
        final original = ChatMessage(id: '1', role: ChatRole.user, text: 'text', timestamp: timestamp, isError: true);

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.role, original.role);
        expect(copy.text, original.text);
        expect(copy.timestamp, original.timestamp);
        expect(copy.isError, original.isError);
      });
    });

    group('toJson / fromJson round-trip', () {
      test('round-trips every field', () {
        final timestamp = DateTime(2024, 3, 15, 10, 30);
        final original = ChatMessage(
          id: '42',
          role: ChatRole.mentor,
          text: 'Invista com sabedoria.',
          timestamp: timestamp,
          isError: true,
        );

        final json = original.toJson();
        final decoded = ChatMessage.fromJson(json);

        expect(decoded.id, original.id);
        expect(decoded.role, original.role);
        expect(decoded.text, original.text);
        expect(decoded.timestamp, original.timestamp);
        expect(decoded.isError, original.isError);
      });

      test('fromJson defaults role to mentor when the value is unrecognized', () {
        final decoded = ChatMessage.fromJson({
          'id': '1',
          'role': 'unknown_role',
          'text': 'hi',
          'timestamp': DateTime(2024, 1, 1).toIso8601String(),
        });

        expect(decoded.role, ChatRole.mentor);
      });

      test('fromJson defaults text to empty string and isError to false when missing', () {
        final decoded = ChatMessage.fromJson({
          'id': '1',
          'role': 'user',
          'timestamp': DateTime(2024, 1, 1).toIso8601String(),
        });

        expect(decoded.text, '');
        expect(decoded.isError, isFalse);
      });

      test('fromJson falls back to now() for an unparseable/missing timestamp', () {
        final before = DateTime.now();
        final decoded = ChatMessage.fromJson({'id': '1', 'role': 'user', 'text': 'hi'});
        final after = DateTime.now();

        expect(decoded.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(decoded.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });
  });

  test('ChatRole has exactly user and mentor', () {
    expect(ChatRole.values, [ChatRole.user, ChatRole.mentor]);
  });
}
