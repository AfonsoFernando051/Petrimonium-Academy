/// The backend's real, server-verified answer to "which achievements does
/// this user have unlocked" (`GET /api/v1/achievements`) — conditions are
/// checked against the user's actual portfolio server-side, and unlocks are
/// persisted, so this survives a reinstall/device change unlike the old
/// local-only achievement state.
class AchievementEvaluationResult {
  final Map<String, DateTime> unlockedAt;
  final Set<String> newlyUnlockedCodes;
  final int achievementXpTotal;

  const AchievementEvaluationResult({
    required this.unlockedAt,
    required this.newlyUnlockedCodes,
    required this.achievementXpTotal,
  });

  static const empty = AchievementEvaluationResult(unlockedAt: {}, newlyUnlockedCodes: {}, achievementXpTotal: 0);

  factory AchievementEvaluationResult.fromJson(Map<String, dynamic> json) {
    final rawUnlockedAt = json['unlockedAt'] as Map<String, dynamic>? ?? const {};
    final rawNewlyUnlocked = json['newlyUnlockedCodes'] as List<dynamic>? ?? const [];
    return AchievementEvaluationResult(
      unlockedAt: rawUnlockedAt.map((code, value) => MapEntry(code, DateTime.parse(value as String))),
      newlyUnlockedCodes: rawNewlyUnlocked.map((code) => code.toString()).toSet(),
      achievementXpTotal: json['achievementXpTotal'] as int? ?? 0,
    );
  }
}
