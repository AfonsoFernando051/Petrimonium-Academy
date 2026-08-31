/// The backend's authoritative answer to completing a lesson
/// (`POST /api/v1/learning/lessons/{id}/complete`) — the real XP/level, not
/// a client-side recomputation. Mirrors `LearningController.LessonCompletionResponseDTO`.
class LessonCompletionResult {
  final String lessonId;
  final bool alreadyCompleted;
  final int xpAwarded;
  final bool moduleCompleted;
  final int moduleXpAwarded;
  final int totalXp;
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;

  const LessonCompletionResult({
    required this.lessonId,
    required this.alreadyCompleted,
    required this.xpAwarded,
    required this.moduleCompleted,
    required this.moduleXpAwarded,
    required this.totalXp,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  factory LessonCompletionResult.fromJson(Map<String, dynamic> json) {
    return LessonCompletionResult(
      lessonId: json['lessonId'] as String,
      alreadyCompleted: json['alreadyCompleted'] as bool? ?? false,
      xpAwarded: json['xpAwarded'] as int? ?? 0,
      moduleCompleted: json['moduleCompleted'] as bool? ?? false,
      moduleXpAwarded: json['moduleXpAwarded'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xpIntoLevel: json['xpIntoLevel'] as int? ?? 0,
      xpForNextLevel: json['xpForNextLevel'] as int? ?? 50,
    );
  }
}
