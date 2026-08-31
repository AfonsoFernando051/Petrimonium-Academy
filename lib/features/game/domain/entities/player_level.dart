/// The user's current level and progress toward the next one, derived from
/// real accumulated XP (see [LevelCalculator]) — never a hardcoded number.
class PlayerLevel {
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;

  const PlayerLevel({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  /// Progress toward the next level, 0.0-1.0.
  double get progress => xpForNextLevel == 0 ? 1.0 : (xpIntoLevel / xpForNextLevel).clamp(0.0, 1.0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerLevel &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          xpIntoLevel == other.xpIntoLevel &&
          xpForNextLevel == other.xpForNextLevel;

  @override
  int get hashCode => Object.hash(level, xpIntoLevel, xpForNextLevel);
}
