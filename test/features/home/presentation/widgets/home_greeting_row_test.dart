import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/home/presentation/widgets/home_greeting_row.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable({String? userName, int? streakDays}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: HomeGreetingRow(userName: userName, streakDays: streakDays)),
    );
  }

  group('HomeGreetingRow', () {
    testWidgets('shows a generic greeting when no name is known', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Bem-vindo de volta'), findsOneWidget);
    });

    testWidgets('shows the real name when known', (tester) async {
      await tester.pumpWidget(buildTestable(userName: 'Camila'));

      expect(find.text('Bem-vindo de volta, Camila'), findsOneWidget);
    });

    testWidgets('shows the streak badge when streakDays is positive', (tester) async {
      await tester.pumpWidget(buildTestable(streakDays: 3));

      expect(find.text('3 dias'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('hides the streak badge at 0 or null', (tester) async {
      await tester.pumpWidget(buildTestable(streakDays: 0));
      expect(find.text('🔥'), findsNothing);

      await tester.pumpWidget(buildTestable(streakDays: null));
      expect(find.text('🔥'), findsNothing);
    });
  });
}
