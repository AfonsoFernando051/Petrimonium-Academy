import 'package:petrimonium/features/academy/domain/entities/lesson.dart';

/// Whether a recommendation is the learner's next new lesson, or a past
/// lesson worth revisiting because it wasn't answered perfectly the first
/// time — see `AcademyRecommendationService`.
enum RecommendationType { continueLearning, review }

/// One "what should I do next" suggestion (`docs/ACADEMY_ENGINE.md` §3d,
/// brief §20/22 "Recommended For You"). [reasonKey] is an `AppStrings` key,
/// translated by the caller — this entity carries no literal UI copy, same
/// discipline `PetMessage` already follows.
class AcademyRecommendation {
  final RecommendationType type;
  final Lesson lesson;
  final String reasonKey;
  final Map<String, String> reasonParams;

  const AcademyRecommendation({
    required this.type,
    required this.lesson,
    required this.reasonKey,
    this.reasonParams = const {},
  });
}
