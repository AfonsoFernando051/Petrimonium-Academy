import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/utils/password_policy.dart';

void main() {
  group('PasswordPolicy.validate', () {
    test('accepts a password meeting every rule', () {
      expect(PasswordPolicy.validate('Str0ngPass'), isNull);
    });

    test('rejects a password shorter than 8 characters', () {
      expect(PasswordPolicy.validate('Ab1'), isNotNull);
    });

    test('rejects a password without an uppercase letter', () {
      expect(PasswordPolicy.validate('lowercase1'), isNotNull);
    });

    test('rejects a password without a lowercase letter', () {
      expect(PasswordPolicy.validate('UPPERCASE1'), isNotNull);
    });

    test('rejects a password without a digit', () {
      expect(PasswordPolicy.validate('NoDigitsHere'), isNotNull);
    });

    test('isValid mirrors validate returning null', () {
      expect(PasswordPolicy.isValid('Str0ngPass'), isTrue);
      expect(PasswordPolicy.isValid('weak'), isFalse);
    });
  });
}
