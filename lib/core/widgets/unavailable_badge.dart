import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';

/// Shared "coming soon" visual language for any control that looks
/// interactive but isn't implemented yet — extracted from the Financial
/// Lab's `_LabTile` pattern (`financial_lab_home_screen.dart`), which was
/// already the one place in the app that got this right: reduced opacity,
/// a small muted label, and hit-testing actually disabled rather than
/// merely styled to look disabled. Reused wherever a false affordance
/// (Search, Sell, Reports, Import) needs the same honest treatment instead
/// of each screen inventing its own variant.
class UnavailableBadge extends StatelessWidget {
  const UnavailableBadge({super.key, this.label});

  /// Defaults to the shared "coming soon" string; pass an override only if
  /// the control's unavailability isn't a "not built yet" case (e.g. a
  /// different `Unavailable`/`Disabled` reason from `AppStrings`).
  final String? label;

  /// The opacity every unavailable control in the app should apply to its
  /// whole subtree — one constant instead of each call site guessing a
  /// number, so "how faded is unavailable" reads the same everywhere.
  static const double opacity = 0.55;

  @override
  Widget build(BuildContext context) {
    return Text(
      (label ?? Translator.translate(AppStrings.labComingSoon)).toUpperCase(),
      style: TextStyle(
        color: context.colors.textTertiary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}
