import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/utils/user_scoped_prefs.dart';

void main() {
  test('falls back to an anonymous scope when no account is logged in', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await UserScopedPrefs.key('some_key'), 'some_key::anonymous');
  });

  test('falls back to an anonymous scope when auth_email is present but empty', () async {
    SharedPreferences.setMockInitialValues({'auth_email': ''});

    expect(await UserScopedPrefs.key('some_key'), 'some_key::anonymous');
  });

  test('scopes to the logged-in account\'s email', () async {
    SharedPreferences.setMockInitialValues({'auth_email': 'user@example.com'});

    expect(await UserScopedPrefs.key('some_key'), 'some_key::user@example.com');
  });

  test('different accounts produce different scoped keys for the same base key', () async {
    SharedPreferences.setMockInitialValues({'auth_email': 'first@example.com'});
    final firstKey = await UserScopedPrefs.key('some_key');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_email', 'second@example.com');
    final secondKey = await UserScopedPrefs.key('some_key');

    expect(firstKey, isNot(secondKey));
  });
}
