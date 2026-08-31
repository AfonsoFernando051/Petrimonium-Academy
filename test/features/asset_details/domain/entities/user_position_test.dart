import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';

void main() {
  group('UserPosition.fromJson', () {
    test('parses all fields from a full response', () {
      final position = UserPosition.fromJson(const {
        'quantity': 10.0,
        'averagePrice': 25.5,
        'investedValue': 255.0,
        'currentValue': 300.0,
        'unrealizedGain': 45.0,
        'unrealizedGainPercent': 17.6,
        'portfolioWeight': 12.5,
      });

      expect(position.quantity, 10.0);
      expect(position.averagePrice, 25.5);
      expect(position.investedValue, 255.0);
      expect(position.currentValue, 300.0);
      expect(position.unrealizedGain, 45.0);
      expect(position.unrealizedGainPercent, 17.6);
      expect(position.portfolioWeight, 12.5);
    });

    test('accepts integer JSON numbers and converts them to double', () {
      final position = UserPosition.fromJson(const {
        'quantity': 10,
        'averagePrice': 25,
        'investedValue': 250,
        'currentValue': 300,
        'unrealizedGain': 50,
        'unrealizedGainPercent': 20,
        'portfolioWeight': 12,
      });

      expect(position.quantity, 10.0);
      expect(position.currentValue, 300.0);
    });

    test('missing fields fall back to 0', () {
      final position = UserPosition.fromJson(const {});

      expect(position.quantity, 0);
      expect(position.averagePrice, 0);
      expect(position.investedValue, 0);
      expect(position.currentValue, 0);
      expect(position.unrealizedGain, 0);
      expect(position.unrealizedGainPercent, 0);
      expect(position.portfolioWeight, 0);
    });
  });
}
