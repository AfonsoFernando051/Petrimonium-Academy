import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';

/// Small uppercase eyebrow label used to separate portfolio sections —
/// matches the style already established in `DashboardScreen`.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: TextStyle(
        color: AppColors.neonCyan.withValues(alpha: 0.5),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      ),
    );
    if (trailing == null) return text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [text, trailing!],
    );
  }
}
