import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/background_presets.dart';

void main() {
  group('BackgroundPresets', () {
    test('resolve returns the matching preset for every intensity', () {
      for (final intensity in BackgroundIntensity.values) {
        expect(BackgroundPresets.resolve(intensity), BackgroundPresets.all[intensity]);
      }
    });

    test('focus is the quietest preset: lowest star count and glow disabled', () {
      final focus = BackgroundPresets.resolve(BackgroundIntensity.focus);

      for (final other in BackgroundIntensity.values) {
        if (other == BackgroundIntensity.focus) continue;
        final preset = BackgroundPresets.resolve(other);
        expect(focus.starCount, lessThanOrEqualTo(preset.starCount));
      }
      expect(focus.glowOpacity, 0.0);
    });

    test('immersive is the most visually dominant preset: highest star count and nebula opacity', () {
      final immersive = BackgroundPresets.resolve(BackgroundIntensity.immersive);

      for (final other in BackgroundIntensity.values) {
        if (other == BackgroundIntensity.immersive) continue;
        final preset = BackgroundPresets.resolve(other);
        expect(immersive.starCount, greaterThanOrEqualTo(preset.starCount));
        expect(immersive.nebulaOpacity, greaterThanOrEqualTo(preset.nebulaOpacity));
      }
    });
  });
}
