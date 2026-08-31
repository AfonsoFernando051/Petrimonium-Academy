import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/mentor/data/datasources/mentor_remote_datasource.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late MentorRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = MentorRemoteDataSource(apiClient: mockApiClient);
  });

  group('sendMessage', () {
    test(
      'posts the message/conversationId/context and parses the reply on 200',
      () async {
        when(
          () =>
              mockApiClient.post(any(), any(), timeout: any(named: 'timeout')),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'reply': 'Hi there',
              'conversationId': 7,
              'title': 'New chat',
            }),
            200,
          ),
        );

        final result = await dataSource.sendMessage(
          message: 'hello',
          conversationId: 3,
          context: {'goal': 'buildWealth'},
        );

        expect(result.reply, 'Hi there');
        expect(result.conversationId, 7);
        expect(result.title, 'New chat');
        verify(
          () => mockApiClient.post(ApiConstants.mentorChatEndpoint, {
            'message': 'hello',
            'conversationId': 3,
            'context': {'goal': 'buildWealth'},
          }, timeout: any(named: 'timeout')),
        ).called(1);
      },
    );

    test(
      'uses a longer timeout than the default, since it waits on an LLM reply',
      () async {
        when(
          () =>
              mockApiClient.post(any(), any(), timeout: any(named: 'timeout')),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'reply': 'Hi there',
              'conversationId': 7,
              'title': 'New chat',
            }),
            200,
          ),
        );

        await dataSource.sendMessage(message: 'hello', context: const {});

        final captured =
            verify(
                  () => mockApiClient.post(
                    any(),
                    any(),
                    timeout: captureAny(named: 'timeout'),
                  ),
                ).captured.single
                as Duration;
        expect(captured, greaterThan(const Duration(seconds: 15)));
      },
    );

    test('throws with the backend detail on a non-200 response', () async {
      when(
        () => mockApiClient.post(any(), any(), timeout: any(named: 'timeout')),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'detail': 'Mentor unavailable'}), 503),
      );

      await expectLater(
        () => dataSource.sendMessage(message: 'hi', context: const {}),
        throwsA(
          predicate(
            (e) =>
                e is Exception && e.toString().contains('Mentor unavailable'),
          ),
        ),
      );
    });
  });

  group('listConversations', () {
    test('parses the conversation summaries on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {
              'id': 1,
              'title': 'Chat A',
              'updatedAt': '2024-01-01T00:00:00.000Z',
            },
          ]),
          200,
        ),
      );

      final result = await dataSource.listConversations();

      expect(result.single.id, 1);
      expect(result.single.title, 'Chat A');
      verify(
        () => mockApiClient.get(ApiConstants.mentorConversationsEndpoint),
      ).called(1);
    });

    test('throws with the backend detail on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'Unauthorized'}), 401),
      );

      await expectLater(
        () => dataSource.listConversations(),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Unauthorized'),
          ),
        ),
      );
    });
  });

  group('getSuggestedPrompts', () {
    test('loads backend-owned prompts on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'suggestions': ['Como começar a investir?', 'O que é um ETF?'],
          }),
          200,
        ),
      );

      final result = await dataSource.getSuggestedPrompts(language: 'en');

      expect(result, ['Como começar a investir?', 'O que é um ETF?']);
      verify(
        () => mockApiClient.get(ApiConstants.mentorSuggestionsEndpoint('en')),
      ).called(1);
    });
  });

  group('getConversationMessages', () {
    test('parses the message list, mapping role/text/timestamp', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'messages': [
              {
                'id': 1,
                'role': 'user',
                'text': 'hi',
                'createdAt': '2024-01-01T00:00:00.000Z',
              },
              {
                'id': 2,
                'role': 'mentor',
                'text': 'hello!',
                'createdAt': '2024-01-01T00:01:00.000Z',
              },
            ],
          }),
          200,
        ),
      );

      final result = await dataSource.getConversationMessages(9);

      expect(result.length, 2);
      expect(result[0].role, ChatRole.user);
      expect(result[1].role, ChatRole.mentor);
      verify(
        () => mockApiClient.get(ApiConstants.mentorConversationEndpoint(9)),
      ).called(1);
    });

    test('throws with the backend detail on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'detail': 'Conversation not found'}),
          404,
        ),
      );

      await expectLater(
        () => dataSource.getConversationMessages(9),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Conversation not found'),
          ),
        ),
      );
    });
  });

  group('renameConversation', () {
    test('patches the title and completes on 204', () async {
      when(
        () => mockApiClient.patch(any(), any()),
      ).thenAnswer((_) async => http.Response('', 204));

      await dataSource.renameConversation(4, 'New title');

      verify(
        () => mockApiClient.patch(ApiConstants.mentorConversationEndpoint(4), {
          'title': 'New title',
        }),
      ).called(1);
    });

    test('throws with the backend detail when the status is not 204', () async {
      when(() => mockApiClient.patch(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'Not found'}), 404),
      );

      await expectLater(
        () => dataSource.renameConversation(4, 'x'),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Not found'),
          ),
        ),
      );
    });
  });

  group('deleteConversation', () {
    test('deletes and completes on 204', () async {
      when(
        () => mockApiClient.delete(any()),
      ).thenAnswer((_) async => http.Response('', 204));

      await dataSource.deleteConversation(4);

      verify(
        () => mockApiClient.delete(ApiConstants.mentorConversationEndpoint(4)),
      ).called(1);
    });

    test('throws with the backend detail when the status is not 204', () async {
      when(() => mockApiClient.delete(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'Not found'}), 404),
      );

      await expectLater(
        () => dataSource.deleteConversation(4),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Not found'),
          ),
        ),
      );
    });
  });
}
