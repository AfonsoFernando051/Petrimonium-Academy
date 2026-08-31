import 'package:shared_preferences/shared_preferences.dart';

/// Scopes a local-only `SharedPreferences` key to the currently logged-in
/// account, so switching accounts on the same device never leaks one user's
/// locally-cached progress (Academy completions, achievements, ...) into
/// another user's session.
///
/// The email saved by `AuthRepository` under the `auth_email` key (read
/// directly here rather than via `AuthRepository`, to avoid a dependency
/// from low-level local-cache repositories onto the auth feature) is the
/// only stable per-account identifier available client-side — there is no
/// decoded JWT claim or numeric user id cached locally. `logout()` clears
/// `auth_email` but deliberately leaves the scoped data behind, so a user
/// who logs back in later finds their progress exactly as they left it.
class UserScopedPrefs {
  static const _authEmailKey = 'auth_email';

  /// Falls back to this scope before any login has ever happened on this
  /// device (or if `auth_email` is somehow missing/empty) — callers must
  /// never operate on a null/empty scope.
  static const _anonymousScope = 'anonymous';

  /// Appends the current account's scope to [baseKey], e.g.
  /// `academy_completed_lesson_ids` becomes
  /// `academy_completed_lesson_ids::user@example.com`.
  static Future<String> key(String baseKey) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_authEmailKey);
    final scope = (email == null || email.isEmpty) ? _anonymousScope : email;
    return '$baseKey::$scope';
  }
}
