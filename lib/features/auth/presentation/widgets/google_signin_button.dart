import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/widgets/game_button.dart';

/// Secondary CTA for "Sign in with Google" — same GameButton chrome as the
/// primary email/password buttons, but a neutral gray gradient (instead of
/// the brand neon) so it reads as an alternative, not the main action.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton(
      label: Translator.translate(AppStrings.continueWithGoogle),
      icon: Icons.g_mobiledata,
      onPressed: onPressed,
      isLoading: isLoading,
      colors: [Colors.blueGrey.shade600, Colors.blueGrey.shade800],
    );
  }
}
