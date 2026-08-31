/// An educational explanation for a financial indicator — displayed
/// when the user taps an indicator tile on the asset details screen.
///
/// These are static educational content, not market data, so they
/// don't need freshness guarantees or provider validation.
class EducationalExplanation {
  final String indicatorId;
  final String title;
  final String definition;
  final String whyItMatters;
  final String caveat;
  final String? petDialogue; // What the pet says when explaining

  const EducationalExplanation({
    required this.indicatorId,
    required this.title,
    required this.definition,
    required this.whyItMatters,
    required this.caveat,
    this.petDialogue,
  });
}
