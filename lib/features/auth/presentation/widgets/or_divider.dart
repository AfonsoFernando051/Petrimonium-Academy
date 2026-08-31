import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/utils/translator.dart';

/// A labeled horizontal rule ("— or —") separating the primary email/password
/// action from the alternative Google sign-in below it.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Row(
      children: [
        Expanded(child: Divider(color: tokens.textTertiary)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            Translator.translate(AppStrings.orDivider),
            style: TextStyle(color: tokens.textTertiary, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: tokens.textTertiary)),
      ],
    );
  }
}
