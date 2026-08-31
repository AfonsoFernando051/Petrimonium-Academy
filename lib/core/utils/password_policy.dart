/// Password strength rule shared by every sign-up entry point in the app.
/// Mirrors the backend's `RegisterRequest` validation (see
/// `PetApp-Backend/.../presentation/auth/dto/RegisterRequest.java`) so a weak
/// password is rejected locally with a clear message instead of round-tripping
/// to the server for a 400.
class PasswordPolicy {
  PasswordPolicy._();

  static const int minLength = 8;

  /// Returns a user-facing message describing the first unmet rule, or
  /// `null` if [password] satisfies the policy.
  static String? validate(String password) {
    if (password.length < minLength) {
      return 'A senha deve ter pelo menos $minLength caracteres.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'A senha deve conter pelo menos uma letra maiúscula.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'A senha deve conter pelo menos uma letra minúscula.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'A senha deve conter pelo menos um número.';
    }
    return null;
  }

  static bool isValid(String password) => validate(password) == null;
}
