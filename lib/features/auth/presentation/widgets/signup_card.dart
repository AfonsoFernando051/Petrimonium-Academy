import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_color_tokens.dart';
import 'signup_form.dart';

class SignupCard extends StatelessWidget {
  const SignupCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: tokens.surface.withValues(alpha: context.isDarkMode ? 0.1 : 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: tokens.border),
              ),
              child: SingleChildScrollView(
                child: const SignupForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
