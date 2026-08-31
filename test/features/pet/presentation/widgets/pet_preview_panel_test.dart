import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/presentation/widgets/pet_preview_panel.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: PetPreviewPanel()),
    );
  }

  group('PetPreviewPanel', () {
    testWidgets('renders the title and every preview row', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('O que vamos fazer juntos'), findsOneWidget);
      expect(find.text('Comemorar cada conquista da sua jornada'), findsOneWidget);
      expect(find.text('Aprender sobre investimentos no seu ritmo'), findsOneWidget);
      expect(find.text('Lembrar dos momentos importantes da nossa jornada'), findsOneWidget);
      expect(find.byIcon(Icons.celebration), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
