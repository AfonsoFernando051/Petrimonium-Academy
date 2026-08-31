import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/knowledge_level.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_level_header.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('AcademyLevelHeader', () {
    testWidgets('renders level, xp and knowledge level text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: AcademyLevelHeader(
              level: 5,
              totalXpEarned: 1234,
              knowledgeLevel: KnowledgeLevel.investor,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      expect(find.byIcon(Icons.psychology_alt_outlined), findsOneWidget);
      expect(find.textContaining('5'), findsWidgets);
      expect(find.textContaining('1234'), findsWidgets);
    });
  });
}
