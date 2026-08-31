/// The backend's authoritative answer to completing a Financial Lab
/// simulator (`POST /api/v1/lab/simulators/{id}/complete`) — the real
/// XP/level, never a client-side recomputation. Mirrors `LabController
/// .SimulatorCompletionResponseDTO` (`docs/DECISIONS.md` DECISION-037).
class SimulatorCompletionResult {
  final String simulatorId;
  final bool alreadyCompleted;
  final int xpAwarded;
  final int totalXp;
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;

  const SimulatorCompletionResult({
    required this.simulatorId,
    required this.alreadyCompleted,
    required this.xpAwarded,
    required this.totalXp,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  factory SimulatorCompletionResult.fromJson(Map<String, dynamic> json) {
    return SimulatorCompletionResult(
      simulatorId: json['simulatorId'] as String,
      alreadyCompleted: json['alreadyCompleted'] as bool? ?? false,
      xpAwarded: json['xpAwarded'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xpIntoLevel: json['xpIntoLevel'] as int? ?? 0,
      xpForNextLevel: json['xpForNextLevel'] as int? ?? 50,
    );
  }
}
