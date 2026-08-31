import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';

void main() {
  group('friendlyErrorMessage', () {
    test('strips the "Exception: " prefix from a plain Exception', () {
      final result = friendlyErrorMessage(Exception('Something specific went wrong'));
      expect(result, 'Something specific went wrong');
    });

    test('maps a SocketException to a connectivity-specific message', () {
      final result = friendlyErrorMessage(const SocketException('Connection refused'));
      expect(result, contains('conectar'));
    });

    test('maps a message mentioning "connection" to the connectivity message', () {
      final result = friendlyErrorMessage(Exception('Connection timed out'));
      expect(result, contains('conectar'));
    });

    test('maps a message mentioning SocketException text (wrapped) to the connectivity message', () {
      final result = friendlyErrorMessage(Exception('SocketException: Failed host lookup'));
      expect(result, contains('conectar'));
    });

    test('an empty message falls back to a generic "something unexpected" message', () {
      final result = friendlyErrorMessage(Exception(''));
      expect(result, isNotEmpty);
      expect(result, isNot('Exception: '));
    });

    test('a specific backend validation message passes through unchanged (minus the prefix)', () {
      final result = friendlyErrorMessage(Exception('password: must be at least 8 characters long'));
      expect(result, 'password: must be at least 8 characters long');
    });

    test('never returns the raw "Exception: " wrapper text', () {
      final result = friendlyErrorMessage(Exception('User already exists'));
      expect(result, isNot(contains('Exception:')));
    });
  });
}
