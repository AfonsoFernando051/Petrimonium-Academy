import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_background.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';

void main() {
  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(
        body: LoginBackground(),
      ),
    );
  }

  group('LoginBackground', () {
    testWidgets('renders the standard CosmicBackground', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(CosmicBackground), findsOneWidget);
    });
  });
}
