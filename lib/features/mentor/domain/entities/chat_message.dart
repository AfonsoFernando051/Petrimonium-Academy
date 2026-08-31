/// Who a [ChatMessage] came from. `mentor` bubbles render through markdown
/// and can carry [ChatMessage.isError] for a friendly in-character failure.
enum ChatRole { user, mentor }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.isError = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime timestamp;
  final bool isError;

  ChatMessage copyWith({String? text, bool? isError}) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      timestamp: timestamp,
      isError: isError ?? this.isError,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: ChatRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => ChatRole.mentor,
      ),
      text: json['text'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      isError: json['isError'] as bool? ?? false,
    );
  }
}
