import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/navigation/wallet_deep_link.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';

void main() {
  group('WalletDeepLink.portfolioHighlight', () {
    test('builds a petrimonium://wallet/portfolio URI with the highlight', () {
      final uri = WalletDeepLink.portfolioHighlight('diversification');
      expect(uri.scheme, 'petrimonium');
      expect(uri.host, 'wallet');
      expect(uri.path, '/portfolio');
      expect(uri.queryParameters, {'highlight': 'diversification'});
    });
  });

  group('WalletDeepLink.forSimulator', () {
    test('uses the simulator\'s stable sourceId, not its enum name', () {
      final uri = WalletDeepLink.forSimulator(LabSimulatorId.compoundInterest);
      expect(uri.queryParameters['highlight'], 'compound_interest');
    });
  });
}
