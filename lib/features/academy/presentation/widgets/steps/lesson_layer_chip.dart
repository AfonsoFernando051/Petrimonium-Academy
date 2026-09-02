import 'package:flutter/material.dart';

/// A small filled pill labeling which "layer" of the data/calculation/Mentor
/// guardrail a lesson step's content belongs to — content, worked example,
/// or practice — always via an explicit text label, never color alone (per
/// the design system's accessibility rule).
class LessonLayerChip extends StatelessWidget {
  const LessonLayerChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6),
      ),
    );
  }
}
