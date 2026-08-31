import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/password_policy.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_background.dart';

/// Second half of the forgot-password flow. The user pastes the reset code
/// emailed to them (see [ForgotPasswordScreen]) alongside a new password —
/// there's no deep-linking infrastructure in this app, so the code is
/// entered manually rather than opened via a link (see the class doc on
/// `ForgotPasswordScreen`).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (token.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      GameSnack.show(context, Translator.translate(AppStrings.resetPasswordFieldsRequiredError), isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      GameSnack.show(context, Translator.translate(AppStrings.resetPasswordMismatchError), isError: true);
      return;
    }

    final passwordError = PasswordPolicy.validate(newPassword);
    if (passwordError != null) {
      GameSnack.show(context, passwordError, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.authRepository.resetPassword(token, newPassword);
      if (mounted) {
        GameSnack.show(context, Translator.translate(AppStrings.resetPasswordSuccessMessage), isSuccess: true);
        // Returns to LoginScreen — the Navigator's first route whenever the
        // user reached this flow unauthenticated (see MyApp._getStartRoute).
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        GameSnack.show(context, friendlyErrorMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LoginBackground(),
          SafeArea(
            child: Column(
              children: [
                const _BackButton(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.password, size: 56, color: tokens.textPrimary),
                            const SizedBox(height: 16),
                            Text(
                              Translator.translate(AppStrings.resetPasswordTitle),
                              style: TextStyle(color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Translator.translate(AppStrings.resetPasswordSubtitle),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: tokens.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              hint: Translator.translate(AppStrings.resetPasswordTokenHint),
                              icon: Icons.vpn_key,
                              controller: _tokenController,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              hint: Translator.translate(AppStrings.resetPasswordNewPasswordHint),
                              icon: Icons.lock,
                              obscure: true,
                              controller: _newPasswordController,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              hint: Translator.translate(AppStrings.confirmPasswordHint),
                              icon: Icons.lock_outline,
                              obscure: true,
                              controller: _confirmPasswordController,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonCyan,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                      )
                                    : Text(
                                        Translator.translate(AppStrings.resetPasswordSubmitButton),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
