import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/wallet_bridge_cta.dart';

void main() {
  setUp(() => Translator.currentLanguage = 'en');

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('WalletBridgeCta', () {
    testWidgets(
      'shows the real-portfolio label and is tappable when onOpenWallet is provided',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          wrap(WalletBridgeCta(onOpenWallet: () => tapped = true)),
        );

        expect(find.text('See this in your real portfolio'), findsOneWidget);
        await tester.tap(find.byType(WalletBridgeCta));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'shows a disabled "coming soon" state when onOpenWallet is null — never a broken link',
      (tester) async {
        await tester.pumpWidget(wrap(const WalletBridgeCta(onOpenWallet: null)));

        expect(find.text('Coming soon in Wallet'), findsOneWidget);
        final button = tester.widget<TextButton>(find.byType(TextButton));
        expect(button.onPressed, isNull);
      },
    );
  });
}
