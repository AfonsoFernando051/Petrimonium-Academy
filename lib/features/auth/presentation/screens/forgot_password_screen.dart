import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_background.dart';

/// First half of the forgot-password flow: collects an email and asks the
/// backend to send a reset link. The backend always answers 200 (to avoid
/// leaking which emails are registered), so this screen always shows the
/// same generic confirmation regardless of whether the account exists.
///
/// **Design tradeoff**: this app has no deep-linking infrastructure, and
/// building one is out of scope for this pass, so the emailed reset code is
/// entered manually on [ResetPasswordScreen] rather than opened via a link —
/// a smaller, still fully real and testable flow. Deep linking can be a
/// follow-up.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await DI.authRepository.requestPasswordReset(email);
      if (mounted) {
        setState(() => _submitted = true);
      }
    } catch (e) {
      if (mounted) {
        GameSnack.show(context, friendlyErrorMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToResetPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
    );
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
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_reset, size: 56, color: tokens.textPrimary),
                            const SizedBox(height: 16),
                            Text(
                              Translator.translate(AppStrings.forgotPasswordTitle),
                              style: TextStyle(color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Translator.translate(AppStrings.forgotPasswordSubtitle),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: tokens.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            if (_submitted) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: tokens.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: tokens.success.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, color: tokens.success),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        Translator.translate(AppStrings.forgotPasswordConfirmationMessage),
                                        style: TextStyle(color: tokens.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              CustomTextField(
                                hint: Translator.translate(AppStrings.forgotPasswordEmailHint),
                                icon: Icons.email,
                                controller: _emailController,
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
                                          Translator.translate(AppStrings.forgotPasswordSendButton),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _goToResetPassword,
                              child: Text(
                                Translator.translate(AppStrings.forgotPasswordHaveCodeLink),
                                style: TextStyle(color: tokens.textSecondary),
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
