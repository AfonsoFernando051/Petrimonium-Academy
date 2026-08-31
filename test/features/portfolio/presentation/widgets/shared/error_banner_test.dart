import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/error_banner.dart';

void main() {
  Widget buildTestableWidget(VoidCallback onRetry) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: ErrorBanner(onRetry: onRetry),
      ),
    );
  }

  group('ErrorBanner', () {
    testWidgets('renders the error message and retry icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(() {}));

      expect(find.text('Não foi possível atualizar seus dados. Puxe para atualizar.'), findsOneWidget);
      expect(find.byIcon(Icons.satellite_alt), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('invokes onRetry when the refresh icon button is tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(() => tapped = true));

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
