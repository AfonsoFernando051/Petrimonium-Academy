import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/game_button.dart';

class SubmitAssessmentButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback? onPressed;

  const SubmitAssessmentButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton(
      label: 'Enviar Respostas',
      onPressed: onPressed,
      isLoading: isSubmitting,
      pulse: true,
      height: 60,
      borderRadius: 30,
      colors: const [Color(0xFF8E2DE2), AppColors.neonCyan],
    );
  }
}
