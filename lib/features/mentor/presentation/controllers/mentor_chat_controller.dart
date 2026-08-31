import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/features/mentor/data/repositories/mentor_chat_repository.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';

const String _fallbackErrorReply =
    'Hmm, algo deu errado ao pensar na resposta 🐾 Vamos tentar de novo daqui a pouco?';

/// Drives the Mentor chat: which conversation is open, its message list,
/// sending state, and a client-side typewriter reveal that simulates
/// streaming over a normal request/response call (real SSE streaming is a
/// documented future step, not implemented in Phase 1 — see
/// docs/AI_MENTOR.md). `conversationId` is `null` for a fresh/unsaved chat —
/// the backend creates the conversation lazily on the first sent message.
class MentorChatController extends ChangeNotifier {
  MentorChatController({required MentorChatRepository repository})
    : _repository = repository;

  final MentorChatRepository _repository;

  int? _conversationId;
  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  bool _isLoadingHistory = true;
  List<String> _suggestedPrompts = const [];
  Timer? _revealTimer;

  int? get conversationId => _conversationId;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  bool get isLoadingHistory => _isLoadingHistory;
  List<String> get suggestedPrompts => List.unmodifiable(_suggestedPrompts);

  /// Set when loading a past conversation's history fails — `MentorScreen`
  /// shows a retry state instead of an indefinite loading spinner.
  String? historyError;

  /// Loads an existing conversation, or clears to a blank/new chat when
  /// [conversationId] is `null`.
  Future<void> loadConversation(int? conversationId) async {
    _revealTimer?.cancel();
    _conversationId = conversationId;
    _messages.clear();
    _isLoadingHistory = conversationId != null;
    historyError = null;
    notifyListeners();

    if (conversationId == null) {
      _isLoadingHistory = false;
      notifyListeners();
      return;
    }

    try {
      final history = await _repository.loadConversation(conversationId);
      _messages.addAll(history);
    } catch (e) {
      historyError = friendlyErrorMessage(e);
    }

    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text, {String? currentScreen}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _messages.add(
      ChatMessage(
        id: _newId(),
        role: ChatRole.user,
        text: trimmed,
        timestamp: DateTime.now(),
      ),
    );
    _isSending = true;
    notifyListeners();

    try {
      final result = await _repository.sendMessage(
        message: trimmed,
        conversationId: _conversationId,
        currentScreen: currentScreen,
      );
      _conversationId = result.conversationId;
      await _revealReply(result.reply, isError: false);
    } catch (e, stackTrace) {
      // Logged rather than silently discarded — a swallowed exception here
      // means the debug console shows nothing when a request fails, which
      // made a real production issue (backend RestTemplate timeout cutting
      // off Claude's reply) far harder to diagnose than it needed to be.
      debugPrint('MentorChatController.sendMessage failed: $e\n$stackTrace');
      await _revealReply(_fallbackErrorReply, isError: true);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> loadSuggestedPrompts() async {
    try {
      _suggestedPrompts = await _repository.loadSuggestedPrompts();
      notifyListeners();
    } catch (e) {
      debugPrint('Mentor suggestions unavailable: $e');
    }
  }

  /// Reveals [fullText] a few characters at a time so a normal (non-streamed)
  /// backend reply still reads as "typing" like the ChatGPT/Claude-style
  /// experience the product spec asks for.
  Future<void> _revealReply(String fullText, {required bool isError}) async {
    final messageId = _newId();
    _messages.add(
      ChatMessage(
        id: messageId,
        role: ChatRole.mentor,
        text: '',
        timestamp: DateTime.now(),
        isError: isError,
      ),
    );
    notifyListeners();

    if (fullText.isEmpty) return;

    final completer = Completer<void>();
    var charIndex = 0;
    const chunkSize = 3;
    const tickDuration = Duration(milliseconds: 16);

    _revealTimer?.cancel();
    _revealTimer = Timer.periodic(tickDuration, (timer) {
      charIndex = min(charIndex + chunkSize, fullText.length);
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          text: fullText.substring(0, charIndex),
        );
        notifyListeners();
      }
      if (charIndex >= fullText.length) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  /// Resets to a blank, unsaved chat — no backend call. Nothing is lost:
  /// every message already sent was persisted server-side the moment it was
  /// sent. Resuming a past conversation, or deleting one, happens from the
  /// separate conversation history screen.
  void startNewChat() {
    _revealTimer?.cancel();
    _conversationId = null;
    _messages.clear();
    unawaited(loadSuggestedPrompts());
    notifyListeners();
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_messages.length}';

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }
}
