import 'package:flutter/material.dart';
import 'package:petrimonium/features/portfolio/domain/enums/insight_priority.dart';

/// A single "Portfolio Insight" card — a rule-based observation derived
/// from the user's real holdings/allocation/history (see
/// `InsightGenerator`), not a machine-learning recommendation.
class Insight {
  final String title;
  final String description;
  final IconData icon;
  final InsightPriority priority;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  const Insight({
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
    required this.color,
    this.actionLabel,
    this.onAction,
  });
}
