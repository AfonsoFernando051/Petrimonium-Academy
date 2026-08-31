/// The authoritative XP/level/streak summary from the backend's XP ledger
/// (`GET /api/v1/gamification/summary`) — includes learning XP, achievement
/// XP, and the real engagement streak, all in one round trip.
class GamificationSummary {
  final int totalXp;
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final int currentStreak;
  final int longestStreak;

  const GamificationSummary({
    required this.totalXp,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.currentStreak,
    required this.longestStreak,
  });

  static const empty = GamificationSummary(
    totalXp: 0,
    level: 1,
    xpIntoLevel: 0,
    xpForNextLevel: 50,
    currentStreak: 0,
    longestStreak: 0,
  );

  factory GamificationSummary.fromJson(Map<String, dynamic> json) {
    return GamificationSummary(
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xpIntoLevel: json['xpIntoLevel'] as int? ?? 0,
      xpForNextLevel: json['xpForNextLevel'] as int? ?? 50,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }
}
