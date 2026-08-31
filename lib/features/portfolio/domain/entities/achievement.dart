import 'package:flutter/material.dart';

/// A permanent, non-revocable unlock (per the project's stated rule:
/// "Achievements are permanent. Once unlocked, they cannot be removed.").
/// [unlocked]/[unlockedAt] reflect what's persisted in
/// `AchievementsLocalDataSource` — evaluating the catalog again after a
/// portfolio dip never flips an already-unlocked achievement back off.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.unlocked,
    this.unlockedAt,
  });

  Achievement copyWith({bool? unlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      xpReward: xpReward,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
