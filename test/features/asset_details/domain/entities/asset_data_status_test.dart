import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_data_status.dart';

void main() {
  group('AssetDataStatus.fromString', () {
    test('parses each enum name case-insensitively', () {
      expect(AssetDataStatus.fromString('fresh'), AssetDataStatus.fresh);
      expect(AssetDataStatus.fromString('FRESH'), AssetDataStatus.fresh);
      expect(AssetDataStatus.fromString('cached'), AssetDataStatus.cached);
      expect(AssetDataStatus.fromString('delayed'), AssetDataStatus.delayed);
      expect(AssetDataStatus.fromString('partial'), AssetDataStatus.partial);
      expect(AssetDataStatus.fromString('unavailable'), AssetDataStatus.unavailable);
      expect(AssetDataStatus.fromString('error'), AssetDataStatus.error);
      expect(AssetDataStatus.fromString('ERROR'), AssetDataStatus.error);
    });

    test('null input falls back to unavailable', () {
      expect(AssetDataStatus.fromString(null), AssetDataStatus.unavailable);
    });

    test('unrecognized input falls back to unavailable', () {
      expect(AssetDataStatus.fromString('not_a_real_status'), AssetDataStatus.unavailable);
      expect(AssetDataStatus.fromString(''), AssetDataStatus.unavailable);
    });
  });
}
