import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/widgets/game_button.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton(
      label: Translator.translate(AppStrings.loginButton),
      icon: Icons.arrow_forward,
      iconTrailing: true,
      onPressed: onPressed,
      isLoading: isLoading,
      pulse: true,
      colors: const [AppColors.neonBlue, AppColors.neonPurple],
    );
  }
}
