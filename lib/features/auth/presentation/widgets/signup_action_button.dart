import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/widgets/game_button.dart';

class SignupActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SignupActionButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton(
      label: Translator.translate(AppStrings.signupButton),
      onPressed: onPressed,
      isLoading: isLoading,
      pulse: true,
      borderRadius: 16,
      colors: const [AppColors.neonViolet, AppColors.neonPink],
    );
  }
}
