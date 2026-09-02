import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/mentor/domain/services/mentor_reply_layers.dart';

void main() {
  group('MentorReplyLayers.tryParse', () {
    test('splits content and interpretation when both markers are present', () {
      final result = MentorReplyLayers.tryParse(
        '[[CONTENT]]\nReserva de emergência é dinheiro acessível.\n[[INTERPRETATION]]\nIsso conecta com sua última aula.',
      );

      expect(result, isNotNull);
      expect(result!.content, 'Reserva de emergência é dinheiro acessível.');
      expect(result.interpretation, 'Isso conecta com sua última aula.');
    });

    test('returns content with a null interpretation when only [[CONTENT]] is present', () {
      final result = MentorReplyLayers.tryParse('[[CONTENT]]\nUma explicação objetiva.');

      expect(result, isNotNull);
      expect(result!.content, 'Uma explicação objetiva.');
      expect(result.interpretation, isNull);
    });

    test('returns null for a plain reply with no markers (short/conversational)', () {
      final result = MentorReplyLayers.tryParse('Oi! Como posso ajudar?');

      expect(result, isNull);
    });

    test('returns null for an empty string', () {
      final result = MentorReplyLayers.tryParse('');

      expect(result, isNull);
    });

    test('treats a blank interpretation section as absent, not an empty string', () {
      final result = MentorReplyLayers.tryParse('[[CONTENT]]\nExplicação.\n[[INTERPRETATION]]\n   ');

      expect(result, isNotNull);
      expect(result!.interpretation, isNull);
    });

    test('returns null when [[CONTENT]] is present but its body is blank', () {
      final result = MentorReplyLayers.tryParse('[[CONTENT]]\n   ');

      expect(result, isNull);
    });
  });
}
