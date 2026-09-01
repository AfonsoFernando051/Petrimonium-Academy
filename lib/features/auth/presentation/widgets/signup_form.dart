import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/utils/game_snack.dart';
import '../../../../core/utils/friendly_error_message.dart';
import '../../../../core/utils/password_policy.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../main.dart';
import 'custom_text_field.dart';
import 'signup_action_button.dart';
import 'google_signin_button.dart';
import 'or_divider.dart';

/// Mirrors the backend's `RegisterRequest` username size — see
/// `PetApp-Backend/.../presentation/auth/dto/RegisterRequest.java`.
const int _minNameLength = 3;

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    // Re-renders on every keystroke so field-level validation below updates
    // live, instead of only surfacing errors after a failed submit.
    for (final controller in [
      _nameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  /// `null` while the field is empty (untouched) or valid — errors only
  /// surface once there's something to correct.
  String? get _nameError {
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length >= _minNameLength) return null;
    return 'Mínimo de $_minNameLength caracteres.';
  }

  String? get _emailError {
    final email = _emailController.text.trim();
    if (email.isEmpty || _emailPattern.hasMatch(email)) return null;
    return 'Digite um e-mail válido.';
  }

  String? get _confirmPasswordError {
    final confirm = _confirmPasswordController.text;
    if (confirm.isEmpty || confirm == _passwordController.text) return null;
    return 'As senhas não coincidem.';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      GameSnack.show(context, 'Preencha todos os campos obrigatórios.', isError: true);
      return;
    }

    // Field-level errors already surface live under each input as the user
    // types (see _nameError/_emailError/_confirmPasswordError/
    // _PasswordRequirementsChecklist) — this is the final gate before
    // hitting the network, reusing the same checks as the single source of
    // truth.
    final passwordError = PasswordPolicy.validate(password);
    final firstError = _nameError ?? _emailError ?? _confirmPasswordError ?? passwordError;
    if (firstError != null) {
      GameSnack.show(context, firstError, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.authRepository.register(name, email, password);
      
      // Auto-login since register doesn't return an accessToken
      await DI.authRepository.login(email, password);

      // Rebuilds fresh from `MyApp._getStartRoute()` — the single source of
      // truth for where a user belongs (meet pet / goal / tutorial /
      // portfolio choice / home) — instead of a separate, narrower redirect.
      if (mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyApp()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        GameSnack.show(
          context,
          'Cadastro falhou: ${friendlyErrorMessage(e)}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _isGoogleLoading = true);
    try {
      await DI.authRepository.loginWithGoogle();

      if (mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyApp()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        GameSnack.show(
          context,
          'Cadastro falhou: ${friendlyErrorMessage(e)}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          hint: Translator.translate(AppStrings.nameHint),
          icon: Icons.person,
          controller: _nameController,
          errorText: _nameError,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.emailOrUserHint),
          icon: Icons.email,
          controller: _emailController,
          errorText: _emailError,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.passwordHint),
          icon: Icons.lock,
          obscure: true,
          controller: _passwordController,
        ),
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          _PasswordRequirementsChecklist(password: _passwordController.text),
        ],
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.confirmPasswordHint),
          icon: Icons.lock_outline,
          obscure: true,
          controller: _confirmPasswordController,
          errorText: _confirmPasswordError,
        ),
        const SizedBox(height: 24),
        SignupActionButton(
          onPressed: _handleRegister,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        const OrDivider(),
        const SizedBox(height: 16),
        GoogleSignInButton(
          onPressed: _handleGoogleSignup,
          isLoading: _isGoogleLoading,
        ),
      ],
    );
  }
}

/// Live checklist for [PasswordPolicy]'s rules — shown under the password
/// field as the user types so they can see what's still missing instead of
/// discovering it only after a failed submit.
class _PasswordRequirementsChecklist extends StatelessWidget {
  final String password;

  const _PasswordRequirementsChecklist({required this.password});

  @override
  Widget build(BuildContext context) {
    final rules = <String, bool>{
      'Mínimo de ${PasswordPolicy.minLength} caracteres': password.length >= PasswordPolicy.minLength,
      'Uma letra maiúscula': password.contains(RegExp(r'[A-Z]')),
      'Uma letra minúscula': password.contains(RegExp(r'[a-z]')),
      'Um número': password.contains(RegExp(r'[0-9]')),
    };

    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: rules.entries.map((rule) {
          final met = rule.value;
          final color = met ? tokens.success : tokens.textTertiary;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  met ? Icons.check_circle : Icons.circle_outlined,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(rule.key, style: TextStyle(color: color, fontSize: 12)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
