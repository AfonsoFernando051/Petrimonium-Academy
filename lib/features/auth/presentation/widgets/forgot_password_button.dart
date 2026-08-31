import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/utils/translator.dart';
import '../screens/forgot_password_screen.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.colors.textSecondary;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        );
      },
      child: Text(
        Translator.translate(AppStrings.forgotPassword),
        style: TextStyle(
          color: textSecondary,
          decoration: TextDecoration.underline,
          decorationColor: textSecondary,
        ),
      ),
    );
  }
}
