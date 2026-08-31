import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/mentor/presentation/widgets/mentor_input_bar.dart';

void main() {
  Widget buildTestableWidget({
    required TextEditingController controller,
    required VoidCallback onSend,
    required bool isSending,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: MentorInputBar(controller: controller, onSend: onSend, isSending: isSending),
      ),
    );
  }

  group('MentorInputBar', () {
    testWidgets('typing text updates the controller', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(controller: controller, onSend: () {}, isSending: false));
      await tester.enterText(find.byType(TextField), 'Qual missão devo completar?');

      expect(controller.text, 'Qual missão devo completar?');
    });

    testWidgets('tapping the send button invokes onSend', (tester) async {
      var sent = false;
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(controller: controller, onSend: () => sent = true, isSending: false));
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();

      expect(sent, isTrue);
    });

    testWidgets('submitting via the keyboard action invokes onSend', (tester) async {
      var sent = false;
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(controller: controller, onSend: () => sent = true, isSending: false));
      await tester.enterText(find.byType(TextField), 'Oi');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      expect(sent, isTrue);
    });

    testWidgets('while sending, the text field is disabled and a spinner replaces the send icon', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(controller: controller, onSend: () {}, isSending: true));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('while sending, tapping the send button area does not invoke onSend', (tester) async {
      var sent = false;
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(controller: controller, onSend: () => sent = true, isSending: true));
      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump();

      expect(sent, isFalse);
    });
  });
}
