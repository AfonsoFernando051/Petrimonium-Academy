import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/mentor/data/repositories/mentor_chat_repository.dart';
import 'package:petrimonium/features/mentor/domain/entities/conversation_summary.dart';
import 'package:petrimonium/features/mentor/presentation/controllers/conversation_list_controller.dart';

class MockMentorChatRepository extends Mock implements MentorChatRepository {}

void main() {
  late MockMentorChatRepository mockRepository;
  late ConversationListController controller;

  setUp(() {
    Translator.currentLanguage = 'pt';
    mockRepository = MockMentorChatRepository();
    controller = ConversationListController(repository: mockRepository);
  });

  group('initial state', () {
    test('starts in a loading state with an empty conversation list and no error', () {
      expect(controller.isLoading, isTrue);
      expect(controller.conversations, isEmpty);
      expect(controller.error, isNull);
    });
  });

  group('load', () {
    test('populates conversations from the repository and clears the loading flag', () async {
      final summaries = [
        ConversationSummary(id: 1, title: 'Dividendos', updatedAt: DateTime(2024, 1, 1)),
        ConversationSummary(id: 2, title: 'ETFs', updatedAt: DateTime(2024, 1, 2)),
      ];
      when(() => mockRepository.listConversations()).thenAnswer((_) async => summaries);

      await controller.load();

      expect(controller.isLoading, isFalse);
      expect(controller.conversations, summaries);
      expect(controller.error, isNull);
    });

    test('handles an empty conversation list', () async {
      when(() => mockRepository.listConversations()).thenAnswer((_) async => []);

      await controller.load();

      expect(controller.isLoading, isFalse);
      expect(controller.conversations, isEmpty);
      expect(controller.error, isNull);
    });

    test('sets a translated error message and clears the loading flag on failure', () async {
      when(() => mockRepository.listConversations()).thenThrow(Exception('backend down'));

      await controller.load();

      expect(controller.isLoading, isFalse);
      expect(controller.error, 'Não foi possível carregar suas conversas.');
      expect(controller.conversations, isEmpty);
    });

    test('clears a previous error on a subsequent successful load', () async {
      when(() => mockRepository.listConversations()).thenThrow(Exception('backend down'));
      await controller.load();
      expect(controller.error, isNotNull);

      final summaries = [ConversationSummary(id: 1, title: 'Dividendos', updatedAt: DateTime(2024, 1, 1))];
      when(() => mockRepository.listConversations()).thenAnswer((_) async => summaries);
      await controller.load();

      expect(controller.error, isNull);
      expect(controller.conversations, summaries);
    });

    test('notifies listeners for the initial loading state and the final settled state', () async {
      when(() => mockRepository.listConversations()).thenAnswer((_) async => []);
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      await controller.load();

      expect(notifyCount, 2);
    });
  });

  group('rename', () {
    test('delegates to the repository and reloads the conversation list', () async {
      when(() => mockRepository.renameConversation(1, 'Novo título')).thenAnswer((_) async {});
      final renamed = [ConversationSummary(id: 1, title: 'Novo título', updatedAt: DateTime(2024, 1, 1))];
      when(() => mockRepository.listConversations()).thenAnswer((_) async => renamed);

      await controller.rename(1, 'Novo título');

      verify(() => mockRepository.renameConversation(1, 'Novo título')).called(1);
      verify(() => mockRepository.listConversations()).called(1);
      expect(controller.conversations, renamed);
      expect(controller.isLoading, isFalse);
    });
  });

  group('delete', () {
    test('delegates to the repository and removes the conversation from the local list', () async {
      final summaries = [
        ConversationSummary(id: 1, title: 'Dividendos', updatedAt: DateTime(2024, 1, 1)),
        ConversationSummary(id: 2, title: 'ETFs', updatedAt: DateTime(2024, 1, 2)),
      ];
      when(() => mockRepository.listConversations()).thenAnswer((_) async => summaries);
      await controller.load();

      when(() => mockRepository.deleteConversation(1)).thenAnswer((_) async {});

      await controller.delete(1);

      verify(() => mockRepository.deleteConversation(1)).called(1);
      expect(controller.conversations.map((c) => c.id), [2]);
      // delete() only mutates the local list — it must not re-fetch from the server.
      verify(() => mockRepository.listConversations()).called(1);
    });

    test('leaves the list unchanged when the deleted id is not present', () async {
      final summaries = [ConversationSummary(id: 1, title: 'Dividendos', updatedAt: DateTime(2024, 1, 1))];
      when(() => mockRepository.listConversations()).thenAnswer((_) async => summaries);
      await controller.load();

      when(() => mockRepository.deleteConversation(99)).thenAnswer((_) async {});
      await controller.delete(99);

      expect(controller.conversations.map((c) => c.id), [1]);
    });

    test('notifies listeners after deletion', () async {
      final summaries = [ConversationSummary(id: 1, title: 'Dividendos', updatedAt: DateTime(2024, 1, 1))];
      when(() => mockRepository.listConversations()).thenAnswer((_) async => summaries);
      await controller.load();
      when(() => mockRepository.deleteConversation(1)).thenAnswer((_) async {});

      var notified = false;
      controller.addListener(() => notified = true);
      await controller.delete(1);

      expect(notified, isTrue);
    });
  });
}
