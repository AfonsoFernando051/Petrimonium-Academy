import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';

void main() {
  Widget buildTestableWidget({
    String hint = 'Hint',
    IconData icon = Icons.email,
    bool obscure = false,
    TextEditingController? controller,
    String? errorText,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: CustomTextField(
          hint: hint,
          icon: icon,
          obscure: obscure,
          controller: controller,
          errorText: errorText,
        ),
      ),
    );
  }

  group('CustomTextField', () {
    testWidgets('renders hint text and icon', (tester) async {
      await tester.pumpWidget(buildTestableWidget(hint: 'Enter email', icon: Icons.email));

      expect(find.text('Enter email'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('accepts text input through its controller', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      await tester.enterText(find.byType(TextField), 'hello world');
      expect(controller.text, 'hello world');
    });

    testWidgets('shows the visibility toggle only when obscure is true, and toggles it', (tester) async {
      await tester.pumpWidget(buildTestableWidget(obscure: true));

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      var textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });

    testWidgets('hides the visibility toggle when obscure is false', (tester) async {
      await tester.pumpWidget(buildTestableWidget(obscure: false));

      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('displays errorText when provided', (tester) async {
      await tester.pumpWidget(buildTestableWidget(errorText: 'Invalid value'));

      expect(find.text('Invalid value'), findsOneWidget);
    });
  });
}
