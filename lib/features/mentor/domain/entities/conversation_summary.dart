/// One entry in the Mentor conversation history list — everything needed to
/// render a row without fetching the full message thread.
class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.lastMessagePreview,
  });

  final int id;
  final String title;
  final DateTime updatedAt;
  final String? lastMessagePreview;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      lastMessagePreview: json['lastMessagePreview'] as String?,
    );
  }
}
