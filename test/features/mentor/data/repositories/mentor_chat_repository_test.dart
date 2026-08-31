import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/mentor/data/datasources/mentor_remote_datasource.dart';
import 'package:petrimonium/features/mentor/data/repositories/mentor_chat_repository.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';
import 'package:petrimonium/features/mentor/domain/entities/conversation_summary.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_preferences_repository.dart';

class MockMentorRemoteDataSource extends Mock
    implements MentorRemoteDataSource {}

void main() {
  late MockMentorRemoteDataSource mockDataSource;
  late PetPreferencesRepository petPreferencesRepository;
  late MentorChatRepository repository;

  setUpAll(() {
    registerFallbackValue(<String, String?>{});
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Translator.currentLanguage = 'pt';
    mockDataSource = MockMentorRemoteDataSource();
    petPreferencesRepository = PetPreferencesRepository();
    repository = MentorChatRepository(
      remoteDataSource: mockDataSource,
      petPreferencesRepository: petPreferencesRepository,
    );
  });

  group('purgeLegacyLocalHistory', () {
    test('removes the old shared on-device cache key', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mentor_chat_history', '[]');

      await repository.purgeLegacyLocalHistory();

      expect(prefs.getString('mentor_chat_history'), isNull);
    });
  });

  group(
    'loadConversation / listConversations / renameConversation / deleteConversation',
    () {
      test('loadConversation delegates to the data source', () async {
        final messages = [
          ChatMessage(
            id: '1',
            role: ChatRole.user,
            text: 'Oi',
            timestamp: DateTime(2024, 1, 1),
          ),
        ];
        when(
          () => mockDataSource.getConversationMessages(7),
        ).thenAnswer((_) async => messages);

        expect(await repository.loadConversation(7), messages);
      });

      test('listConversations delegates to the data source', () async {
        final summaries = [
          ConversationSummary(
            id: 1,
            title: 'Dividendos',
            updatedAt: DateTime(2024, 1, 1),
          ),
        ];
        when(
          () => mockDataSource.listConversations(),
        ).thenAnswer((_) async => summaries);

        expect(await repository.listConversations(), summaries);
      });

      test('loadSuggestedPrompts delegates to the data source', () async {
        when(
          () => mockDataSource.getSuggestedPrompts(language: 'pt'),
        ).thenAnswer((_) async => ['O que é um ETF?']);

        expect(await repository.loadSuggestedPrompts(), ['O que é um ETF?']);
      });

      test('renameConversation delegates to the data source', () async {
        when(
          () => mockDataSource.renameConversation(1, 'Novo título'),
        ).thenAnswer((_) async {});

        await repository.renameConversation(1, 'Novo título');

        verify(
          () => mockDataSource.renameConversation(1, 'Novo título'),
        ).called(1);
      });

      test('deleteConversation delegates to the data source', () async {
        when(
          () => mockDataSource.deleteConversation(1),
        ).thenAnswer((_) async {});

        await repository.deleteConversation(1);

        verify(() => mockDataSource.deleteConversation(1)).called(1);
      });
    },
  );

  group('sendMessage', () {
    test(
      'sends the message with the user\'s saved goal/horizon and current language as context',
      () async {
        await petPreferencesRepository.saveGoal(PetGoalEnum.retireEarly);
        await petPreferencesRepository.saveHorizon(
          InvestmentHorizonEnum.longTerm,
        );
        when(
          () => mockDataSource.sendMessage(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            context: any(named: 'context'),
          ),
        ).thenAnswer(
          (_) async =>
              const MentorChatResult(reply: 'reply', conversationId: 1),
        );

        await repository.sendMessage(message: 'Oi', currentScreen: 'mentor');

        final captured =
            verify(
                  () => mockDataSource.sendMessage(
                    message: any(named: 'message'),
                    conversationId: any(named: 'conversationId'),
                    context: captureAny(named: 'context'),
                  ),
                ).captured.single
                as Map<String, String?>;

        expect(captured['petGoal'], PetGoalEnum.retireEarly.label);
        expect(
          captured['investmentHorizon'],
          InvestmentHorizonEnum.longTerm.label,
        );
        expect(captured['currentScreen'], 'mentor');
        expect(captured['language'], 'pt');
      },
    );

    test(
      'passes the given conversationId through to the data source',
      () async {
        when(
          () => mockDataSource.sendMessage(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            context: any(named: 'context'),
          ),
        ).thenAnswer(
          (_) async =>
              const MentorChatResult(reply: 'reply', conversationId: 42),
        );

        await repository.sendMessage(message: 'Oi', conversationId: 42);

        verify(
          () => mockDataSource.sendMessage(
            message: any(named: 'message'),
            conversationId: 42,
            context: any(named: 'context'),
          ),
        ).called(1);
      },
    );

    test('returns the result from the data source', () async {
      when(
        () => mockDataSource.sendMessage(
          message: any(named: 'message'),
          conversationId: any(named: 'conversationId'),
          context: any(named: 'context'),
        ),
      ).thenAnswer(
        (_) async => const MentorChatResult(
          reply: 'Claro, posso ajudar!',
          conversationId: 5,
          title: 'Dúvida',
        ),
      );

      final result = await repository.sendMessage(message: 'Oi');

      expect(result.reply, 'Claro, posso ajudar!');
      expect(result.conversationId, 5);
      expect(result.title, 'Dúvida');
    });
  });
}
