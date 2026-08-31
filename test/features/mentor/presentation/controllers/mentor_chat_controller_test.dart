import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/features/mentor/data/datasources/mentor_remote_datasource.dart';
import 'package:petrimonium/features/mentor/data/repositories/mentor_chat_repository.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';
import 'package:petrimonium/features/mentor/presentation/controllers/mentor_chat_controller.dart';

class MockMentorChatRepository extends Mock implements MentorChatRepository {}

void main() {
  late MockMentorChatRepository mockRepository;
  late MentorChatController controller;

  setUp(() {
    mockRepository = MockMentorChatRepository();
    controller = MentorChatController(repository: mockRepository);
  });

  tearDown(() {
    controller.dispose();
  });

  group('loadConversation', () {
    test(
      'with an id, populates messages from the repository and clears the loading flag',
      () async {
        final history = [
          ChatMessage(
            id: '1',
            role: ChatRole.user,
            text: 'Oi',
            timestamp: DateTime(2024, 1, 1),
          ),
          ChatMessage(
            id: '2',
            role: ChatRole.mentor,
            text: 'Olá!',
            timestamp: DateTime(2024, 1, 1),
          ),
        ];
        when(
          () => mockRepository.loadConversation(7),
        ).thenAnswer((_) async => history);

        await controller.loadConversation(7);

        expect(controller.isLoadingHistory, isFalse);
        expect(controller.messages, history);
        expect(controller.conversationId, 7);
      },
    );

    test(
      'with null, clears to a blank chat without calling the repository',
      () async {
        await controller.loadConversation(null);

        expect(controller.isLoadingHistory, isFalse);
        expect(controller.messages, isEmpty);
        expect(controller.conversationId, isNull);
        verifyNever(() => mockRepository.loadConversation(any()));
      },
    );

    test('messages is unmodifiable', () async {
      when(
        () => mockRepository.loadConversation(1),
      ).thenAnswer((_) async => []);
      await controller.loadConversation(1);

      expect(
        () => controller.messages.add(
          ChatMessage(
            id: 'x',
            role: ChatRole.user,
            text: 'x',
            timestamp: DateTime.now(),
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('sendMessage — happy path', () {
    test(
      'appends the user message immediately, then the revealed mentor reply',
      () async {
        when(
          () => mockRepository.sendMessage(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            currentScreen: any(named: 'currentScreen'),
          ),
        ).thenAnswer(
          (_) async => const MentorChatResult(
            reply: 'Claro, posso ajudar!',
            conversationId: 1,
          ),
        );

        await controller.sendMessage(
          'O que são dividendos?',
          currentScreen: 'mentor',
        );

        expect(controller.messages.length, 2);
        expect(controller.messages[0].role, ChatRole.user);
        expect(controller.messages[0].text, 'O que são dividendos?');
        expect(controller.messages[1].role, ChatRole.mentor);
        expect(controller.messages[1].text, 'Claro, posso ajudar!');
        expect(controller.messages[1].isError, isFalse);
        expect(controller.isSending, isFalse);
      },
    );

    test(
      'adopts the conversationId returned by the repository on the first send',
      () async {
        when(
          () => mockRepository.sendMessage(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            currentScreen: any(named: 'currentScreen'),
          ),
        ).thenAnswer(
          (_) async => const MentorChatResult(reply: 'ok', conversationId: 99),
        );

        expect(controller.conversationId, isNull);
        await controller.sendMessage('Oi');

        expect(controller.conversationId, 99);
      },
    );

    test(
      'passes the trimmed text and current conversationId to the repository',
      () async {
        when(
          () => mockRepository.sendMessage(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            currentScreen: any(named: 'currentScreen'),
          ),
        ).thenAnswer(
          (_) async => const MentorChatResult(reply: 'ok', conversationId: 1),
        );

        await controller.sendMessage('  Qual missão devo completar?  ');

        final captured = verify(
          () => mockRepository.sendMessage(
            message: captureAny(named: 'message'),
            conversationId: any(named: 'conversationId'),
            currentScreen: any(named: 'currentScreen'),
          ),
        ).captured;
        expect(captured.single, 'Qual missão devo completar?');
      },
    );

    test('ignores a blank/whitespace-only message', () async {
      await controller.sendMessage('   ');

      expect(controller.messages, isEmpty);
      verifyNever(
        () => mockRepository.sendMessage(
          message: any(named: 'message'),
          conversationId: any(named: 'conversationId'),
          currentScreen: any(named: 'currentScreen'),
        ),
      );
    });

    test('ignores a new send while one is already in flight', () async {
      when(
        () => mockRepository.sendMessage(
          message: any(named: 'message'),
          conversationId: any(named: 'conversationId'),
          currentScreen: any(named: 'currentScreen'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return const MentorChatResult(reply: 'ok', conversationId: 1);
      });

      final first = controller.sendMessage('primeira');
      final second = controller.sendMessage('segunda, deve ser ignorada');
      await Future.wait([first, second]);

      // Only the first user message should have been appended.
      expect(
        controller.messages.where((m) => m.role == ChatRole.user).length,
        1,
      );
      expect(controller.messages.first.text, 'primeira');
    });
  });

  group('sendMessage — failure', () {
    test(
      'reveals the fallback error reply and marks it as an error, without throwing',
      () async {
        when(
          () => mockRepository.sendMessage(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            currentScreen: any(named: 'currentScreen'),
          ),
        ).thenThrow(Exception('backend down'));

        await controller.sendMessage('Oi');

        expect(controller.messages.length, 2);
        expect(controller.messages[1].role, ChatRole.mentor);
        expect(controller.messages[1].isError, isTrue);
        expect(controller.messages[1].text, isNotEmpty);
        expect(controller.isSending, isFalse);
      },
    );
  });

  group('startNewChat', () {
    test(
      'empties the message list, resets conversationId and refreshes prompts',
      () async {
        when(
          () => mockRepository.sendMessage(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            currentScreen: any(named: 'currentScreen'),
          ),
        ).thenAnswer(
          (_) async => const MentorChatResult(reply: 'ok', conversationId: 1),
        );
        when(
          () => mockRepository.loadSuggestedPrompts(),
        ).thenAnswer((_) async => ['Como começar a investir?']);
        await controller.sendMessage('Oi');
        expect(controller.messages, isNotEmpty);

        controller.startNewChat();

        expect(controller.messages, isEmpty);
        expect(controller.conversationId, isNull);
        await Future<void>.delayed(Duration.zero);
        verify(() => mockRepository.loadSuggestedPrompts()).called(1);
      },
    );
  });
}
