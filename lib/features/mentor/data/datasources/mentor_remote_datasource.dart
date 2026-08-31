import 'dart:convert';

import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/network/api_error_parser.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';
import 'package:petrimonium/features/mentor/domain/entities/conversation_summary.dart';

/// Result of a `POST /api/mentor/chat` call — besides the reply text, the
/// backend now also returns which conversation it was persisted to (created
/// on the fly the first time) and its (possibly just-set) title.
class MentorChatResult {
  const MentorChatResult({
    required this.reply,
    required this.conversationId,
    this.title,
  });

  final String reply;
  final int conversationId;
  final String? title;
}

/// Thin HTTP layer over `/api/mentor/*`. The backend builds the real
/// portfolio/pet context server-side from the authenticated user, and now
/// also owns conversation/message persistence — this only carries the
/// message, which conversation it belongs to, and mobile-local signals
/// (goal, horizon, current screen, language) the server has no way to know.
class MentorRemoteDataSource {
  final ApiClient apiClient;

  MentorRemoteDataSource({required this.apiClient});

  /// [ApiClient]'s default 15s timeout is sized for ordinary database-backed
  /// endpoints. The Mentor reply waits on an LLM call (adaptive thinking +
  /// portfolio/Academy context can comfortably take 10+ seconds even on a
  /// fast connection) — a client-side timeout here fires before the backend
  /// even finishes, surfacing a generic "something went wrong" bubble on a
  /// request that was actually succeeding server-side.
  static const _chatTimeout = Duration(seconds: 45);

  Future<MentorChatResult> sendMessage({
    required String message,
    int? conversationId,
    required Map<String, String?> context,
  }) async {
    final response = await apiClient.post(ApiConstants.mentorChatEndpoint, {
      'message': message,
      'conversationId': conversationId,
      'context': context,
    }, timeout: _chatTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback: 'Mentor chat request failed (${response.statusCode})',
        ),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return MentorChatResult(
      reply: data['reply'] as String,
      conversationId: data['conversationId'] as int,
      title: data['title'] as String?,
    );
  }

  Future<List<ConversationSummary>> listConversations() async {
    final response = await apiClient.get(
      ApiConstants.mentorConversationsEndpoint,
    );

    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback: 'Failed to load conversations (${response.statusCode})',
        ),
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ConversationSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getSuggestedPrompts({required String language}) async {
    final response = await apiClient.get(
      ApiConstants.mentorSuggestionsEndpoint(language),
    );
    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback:
              'Failed to load Mentor suggestions (${response.statusCode})',
        ),
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['suggestions'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .where((prompt) => prompt.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<List<ChatMessage>> getConversationMessages(int conversationId) async {
    final response = await apiClient.get(
      ApiConstants.mentorConversationEndpoint(conversationId),
    );

    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback: 'Failed to load conversation (${response.statusCode})',
        ),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final messages = data['messages'] as List<dynamic>;
    return messages.map((e) {
      final json = e as Map<String, dynamic>;
      return ChatMessage(
        id: (json['id'] as int).toString(),
        role: json['role'] == 'user' ? ChatRole.user : ChatRole.mentor,
        text: json['text'] as String? ?? '',
        timestamp:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  Future<void> renameConversation(int conversationId, String title) async {
    final response = await apiClient.patch(
      ApiConstants.mentorConversationEndpoint(conversationId),
      {'title': title},
    );

    if (response.statusCode != 204) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback: 'Failed to rename conversation (${response.statusCode})',
        ),
      );
    }
  }

  Future<void> deleteConversation(int conversationId) async {
    final response = await apiClient.delete(
      ApiConstants.mentorConversationEndpoint(conversationId),
    );

    if (response.statusCode != 204) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback: 'Failed to delete conversation (${response.statusCode})',
        ),
      );
    }
  }
}
