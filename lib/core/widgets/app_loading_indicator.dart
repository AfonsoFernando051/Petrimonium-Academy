import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// The app's standard "this section is loading" state — a centered primary
/// spinner. Used for whole-screen/whole-section loading; button-internal
/// spinners (e.g. `GameButton`'s `isLoading`) intentionally keep their own
/// white spinner, since they sit on a colored background.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.strokeWidth = 4.0});

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colors.primary, strokeWidth: strokeWidth),
    );
  }
}
