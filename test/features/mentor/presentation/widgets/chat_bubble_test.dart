import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';
import 'package:petrimonium/features/mentor/presentation/widgets/chat_bubble.dart';

void main() {
  Widget buildTestableWidget(ChatMessage message) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: ChatBubble(message: message)),
    );
  }

  group('ChatBubble', () {
    testWidgets('renders a user message as plain right-aligned text', (tester) async {
      final message = ChatMessage(
        id: '1',
        role: ChatRole.user,
        text: 'O que são dividendos?',
        timestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(buildTestableWidget(message));

      expect(find.text('O que são dividendos?'), findsOneWidget);
      expect(find.byType(MarkdownBody), findsNothing);

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('renders a mentor message left-aligned with markdown', (tester) async {
      final message = ChatMessage(
        id: '2',
        role: ChatRole.mentor,
        text: '**Claro!** Posso ajudar.',
        timestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(buildTestableWidget(message));

      expect(find.byType(MarkdownBody), findsOneWidget);
      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('renders an empty mentor message without a MarkdownBody (typewriter reveal in progress)', (tester) async {
      final message = ChatMessage(
        id: '3',
        role: ChatRole.mentor,
        text: '',
        timestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(buildTestableWidget(message));

      expect(find.byType(MarkdownBody), findsNothing);
    });

    testWidgets('an error mentor message still renders through the mentor (markdown) path', (tester) async {
      final message = ChatMessage(
        id: '4',
        role: ChatRole.mentor,
        text: 'Algo deu errado.',
        timestamp: DateTime(2024, 1, 1),
        isError: true,
      );

      await tester.pumpWidget(buildTestableWidget(message));

      expect(find.byType(MarkdownBody), findsOneWidget);
      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });
  });
}
