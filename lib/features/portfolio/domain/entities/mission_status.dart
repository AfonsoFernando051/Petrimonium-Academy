enum MissionPeriod { daily, weekly }

MissionPeriod _periodFromJson(String raw) {
  switch (raw) {
    case 'WEEKLY':
      return MissionPeriod.weekly;
    case 'DAILY':
    default:
      return MissionPeriod.daily;
  }
}

/// The backend's real, server-verified state of a single mission's current
/// period instance (`GET /api/v1/missions`) — progress, target, and
/// completion are all computed live from the user's actual lesson/module
/// completion history, never client-supplied. Title/description/icon are
/// display-only and resolved client-side from [MissionCatalog], mirroring
/// how [Achievement]'s display metadata is layered onto the backend's real
/// unlock state.
class MissionStatus {
  final String code;
  final MissionPeriod period;
  final String periodKey;
  final int progress;
  final int target;
  final int xpReward;
  final bool completed;

  const MissionStatus({
    required this.code,
    required this.period,
    required this.periodKey,
    required this.progress,
    required this.target,
    required this.xpReward,
    required this.completed,
  });

  factory MissionStatus.fromJson(Map<String, dynamic> json) {
    return MissionStatus(
      code: json['code'] as String,
      period: _periodFromJson(json['period'] as String),
      periodKey: json['periodKey'] as String,
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int? ?? 1,
      xpReward: json['xpReward'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

/// The backend's real answer to "what's the state of every mission this
/// period" (`GET /api/v1/missions`) — same shape as
/// `AchievementEvaluationResult`, but scoped to the mission system.
class MissionEvaluationResult {
  final List<MissionStatus> missions;
  final Set<String> newlyCompletedCodes;
  final int missionXpTotal;

  const MissionEvaluationResult({
    required this.missions,
    required this.newlyCompletedCodes,
    required this.missionXpTotal,
  });

  static const empty = MissionEvaluationResult(missions: [], newlyCompletedCodes: {}, missionXpTotal: 0);

  factory MissionEvaluationResult.fromJson(Map<String, dynamic> json) {
    final rawMissions = json['missions'] as List<dynamic>? ?? const [];
    final rawNewlyCompleted = json['newlyCompletedCodes'] as List<dynamic>? ?? const [];
    return MissionEvaluationResult(
      missions: rawMissions.map((m) => MissionStatus.fromJson(m as Map<String, dynamic>)).toList(),
      newlyCompletedCodes: rawNewlyCompleted.map((code) => code.toString()).toSet(),
      missionXpTotal: json['missionXpTotal'] as int? ?? 0,
    );
  }
}
