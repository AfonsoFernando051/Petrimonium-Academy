import 'package:flutter/material.dart';
import '../../../../core/widgets/cosmic_background.dart';

/// Same gradient-plus-starfield background every other Academy screen
/// uses — see [CosmicBackground]. Previously overrode it with
/// `questionary_space_paw.png`, a leftover artwork asset from an earlier
/// design pass, which read as off-brand against the Notion mockups' plain
/// cosmic background.
class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CosmicBackground(child: SizedBox.shrink());
  }
}
