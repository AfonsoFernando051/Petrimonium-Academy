import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/mentor/data/datasources/mentor_remote_datasource.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';
import 'package:petrimonium/features/mentor/domain/entities/conversation_summary.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_preferences_repository.dart';

/// Facade over the Mentor conversation API. Conversations and messages are
/// now persisted server-side, scoped to the authenticated user — this class
/// no longer caches chat history on-device (see [purgeLegacyLocalHistory]
/// for the one-time cleanup of the old shared cache that predates this).
class MentorChatRepository {
  MentorChatRepository({
    required MentorRemoteDataSource remoteDataSource,
    required PetPreferencesRepository petPreferencesRepository,
  }) : _remoteDataSource = remoteDataSource,
       _petPreferencesRepository = petPreferencesRepository;

  /// Key the old (pre-backend-persistence) SharedPreferences cache used —
  /// shared by whoever was last logged in on a device, which was the bug
  /// this whole feature replaces. Nothing reads it anymore; only purged.
  static const _legacyHistoryKey = 'mentor_chat_history';

  final MentorRemoteDataSource _remoteDataSource;
  final PetPreferencesRepository _petPreferencesRepository;

  Future<void> purgeLegacyLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyHistoryKey);
  }

  Future<List<ChatMessage>> loadConversation(int conversationId) {
    return _remoteDataSource.getConversationMessages(conversationId);
  }

  Future<List<ConversationSummary>> listConversations() {
    return _remoteDataSource.listConversations();
  }

  Future<List<String>> loadSuggestedPrompts() {
    return _remoteDataSource.getSuggestedPrompts(
      language: Translator.currentLanguage,
    );
  }

  Future<void> renameConversation(int conversationId, String title) {
    return _remoteDataSource.renameConversation(conversationId, title);
  }

  Future<void> deleteConversation(int conversationId) {
    return _remoteDataSource.deleteConversation(conversationId);
  }

  Future<MentorChatResult> sendMessage({
    required String message,
    int? conversationId,
    String? currentScreen,
  }) async {
    final goal = await _petPreferencesRepository.loadGoal();
    final horizon = await _petPreferencesRepository.loadHorizon();

    return _remoteDataSource.sendMessage(
      message: message,
      conversationId: conversationId,
      context: {
        'petGoal': goal.label,
        'investmentHorizon': horizon.label,
        'currentScreen': currentScreen,
        'language': Translator.currentLanguage,
      },
    );
  }
}
