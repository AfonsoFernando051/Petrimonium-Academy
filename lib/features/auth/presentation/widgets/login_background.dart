import 'package:flutter/material.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/widgets/cosmic_background.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CosmicBackground(
      assetPath: 'assets/images/questionary_space_paw.png',
      darken: 0.2,
      showArtworkInLightMode: true,
      errorBuilder: (context, error, stackTrace) {
        final tokens = context.colors;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tokens.backgroundPrimary, tokens.surface, tokens.backgroundSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
