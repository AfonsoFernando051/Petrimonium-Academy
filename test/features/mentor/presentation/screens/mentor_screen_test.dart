import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/mentor/data/datasources/mentor_remote_datasource.dart';
import 'package:petrimonium/features/mentor/data/repositories/mentor_chat_repository.dart';
import 'package:petrimonium/features/mentor/presentation/screens/mentor_screen.dart';
import 'package:petrimonium/features/mentor/presentation/widgets/chat_bubble.dart';
import 'package:petrimonium/features/mentor/presentation/widgets/mentor_input_bar.dart';
import 'package:petrimonium/features/mentor/presentation/widgets/suggested_prompt_chip.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';

class MockMentorChatRepository extends Mock implements MentorChatRepository {}

class MockPetRepository extends Mock implements PetRepository {}

void main() {
  late MockMentorChatRepository mockMentorChatRepository;
  late MockPetRepository mockPetRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';

    mockMentorChatRepository = MockMentorChatRepository();
    DI.mentorChatRepository = mockMentorChatRepository;
    when(
      () => mockMentorChatRepository.purgeLegacyLocalHistory(),
    ).thenAnswer((_) async {});
    when(
      () => mockMentorChatRepository.loadSuggestedPrompts(),
    ).thenAnswer((_) async => ['Como começar a investir?', 'O que é um ETF?']);

    mockPetRepository = MockPetRepository();
    DI.petRepository = mockPetRepository;
    when(() => mockPetRepository.getMyPet()).thenAnswer((_) async => null);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: MentorScreen()),
    );
  }

  group('MentorScreen', () {
    testWidgets(
      'shows the header, empty state and suggested prompts on a fresh chat',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Seu Mentor'), findsOneWidget);
        expect(
          find.text('Oi! Posso te ajudar a entender qualquer conceito da sua trilha.'),
          findsOneWidget,
        );
        expect(find.byType(SuggestedPromptChip), findsWidgets);
        expect(find.text('Como começar a investir?'), findsOneWidget);
        expect(find.byType(MentorInputBar), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a suggested prompt sends it and renders both bubbles',
      (tester) async {
        when(
          () => mockMentorChatRepository.sendMessage(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            currentScreen: any(named: 'currentScreen'),
          ),
        ).thenAnswer(
          (_) async => const MentorChatResult(
            reply: 'Dividendos são...',
            conversationId: 1,
            title: 'Dividendos',
          ),
        );

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.byType(SuggestedPromptChip).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        verify(
          () => mockMentorChatRepository.sendMessage(
            message: 'Como começar a investir?',
            conversationId: any(named: 'conversationId'),
            currentScreen: 'mentor',
          ),
        ).called(1);
        expect(find.byType(ChatBubble), findsWidgets);
        expect(find.text('Dividendos são...'), findsOneWidget);
        // A same-day conversation gets exactly one "Hoje" date divider,
        // shown once above the first message.
        expect(find.text('Hoje'), findsOneWidget);
      },
    );

    testWidgets('typing a message and tapping send clears the input field', (
      tester,
    ) async {
      when(
        () => mockMentorChatRepository.sendMessage(
          message: any(named: 'message'),
          conversationId: any(named: 'conversationId'),
          currentScreen: any(named: 'currentScreen'),
        ),
      ).thenAnswer(
        (_) async => const MentorChatResult(reply: 'Olá!', conversationId: 2),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(find.byType(TextField), 'Oi mentor');
      await tester.pump();
      expect(find.text('Oi mentor'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The sent text now also appears as its own ChatBubble echo, so
      // check the TextField's own controller text rather than find.text().
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
      verify(
        () => mockMentorChatRepository.sendMessage(
          message: 'Oi mentor',
          conversationId: any(named: 'conversationId'),
          currentScreen: 'mentor',
        ),
      ).called(1);
    });
  });
}
