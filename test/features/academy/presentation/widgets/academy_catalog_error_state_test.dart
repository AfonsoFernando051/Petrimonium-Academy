import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_catalog_error_state.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable(VoidCallback onRetry) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AcademyCatalogErrorState(onRetry: onRetry)),
    );
  }

  group('AcademyCatalogErrorState', () {
    testWidgets('renders error icon, title, body and retry button', (tester) async {
      await tester.pumpWidget(buildTestable(() {}));

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.byType(GameButton), findsOneWidget);
    });

    testWidgets('invokes onRetry when the retry button is tapped', (tester) async {
      var retried = false;
      await tester.pumpWidget(buildTestable(() => retried = true));

      await tester.tap(find.byType(GameButton));
      await tester.pump();

      expect(retried, isTrue);
    });
  });
}
