import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';

void main() {
  Widget buildTestableWidget({double? strokeWidth}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: strokeWidth == null
            ? const AppLoadingIndicator()
            : AppLoadingIndicator(strokeWidth: strokeWidth),
      ),
    );
  }

  group('AppLoadingIndicator', () {
    testWidgets('renders a centered CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('defaults strokeWidth to 4.0', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(indicator.strokeWidth, 4.0);
    });

    testWidgets('honors a custom strokeWidth', (tester) async {
      await tester.pumpWidget(buildTestableWidget(strokeWidth: 8.0));

      final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(indicator.strokeWidth, 8.0);
    });

    testWidgets('colors the spinner with the theme primary color', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(indicator.color, AppTheme.dark.extension<AppColorTokens>()?.primary);
    });
  });
}
