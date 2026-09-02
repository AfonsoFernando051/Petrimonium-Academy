/// Splits a Mentor chat reply into its "content" (objective explanation)
/// and "interpretation" (the Mentor's personalized read) layers, per the
/// two-marker format the Academy system prompt asks the model to use when
/// explaining a concept (see the backend's `MentorSystemPromptBuilder`,
/// `STRUCTURED_RESPONSE_INSTRUCTION`) — fixed English markers regardless of
/// the reply's own language, so parsing doesn't need a per-language table.
///
/// A short conversational reply (a greeting, an acknowledgment) has no real
/// interpretation layer to separate out — the prompt deliberately leaves the
/// markers optional rather than forcing a fabricated split, and a message
/// persisted before this format existed has none either. [tryParse] returns
/// `null` in both cases, so the caller renders the raw text as before.
class MentorReplyLayers {
  const MentorReplyLayers({required this.content, this.interpretation});

  final String content;

  /// `null` when the reply had a [content] marker but no interpretation
  /// section — a valid, honest state (a purely factual answer has nothing
  /// to interpret), not a parsing failure.
  final String? interpretation;

  static const _contentMarker = '[[CONTENT]]';
  static const _interpretationMarker = '[[INTERPRETATION]]';

  static MentorReplyLayers? tryParse(String text) {
    final contentIndex = text.indexOf(_contentMarker);
    if (contentIndex == -1) return null;

    final interpretationIndex = text.indexOf(_interpretationMarker, contentIndex);
    final content = (interpretationIndex == -1
            ? text.substring(contentIndex + _contentMarker.length)
            : text.substring(contentIndex + _contentMarker.length, interpretationIndex))
        .trim();
    if (content.isEmpty) return null;

    final interpretation = interpretationIndex == -1
        ? null
        : text.substring(interpretationIndex + _interpretationMarker.length).trim();

    return MentorReplyLayers(
      content: content,
      interpretation: (interpretation == null || interpretation.isEmpty) ? null : interpretation,
    );
  }
}
