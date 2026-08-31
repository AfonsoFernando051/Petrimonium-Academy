import 'package:flutter/material.dart';

/// How visually dominant [CosmicBackground] should be for the screen it sits
/// behind. The rule of thumb across the app: the more cognitively demanding
/// the screen, the quieter the background — see each value's docs.
enum BackgroundIntensity {
  /// Home/Dashboard. The cosmic identity at its most expressive: visible
  /// nebula, the fullest star density, a soft ambient glow.
  immersive,

  /// Portfolio, Dividends — money screens. Clearly the same universe, but
  /// dialed back so numbers and charts win the contrast battle.
  balanced,

  /// Academy home, module list — browsing/progression screens. The user
  /// should feel "still inside the game", not "looking at a space scene".
  subtle,

  /// Lesson, quiz/exercise steps. Maximum readability and concentration —
  /// the background should almost disappear from conscious attention.
  focus,

  /// Mentor. Deserves more personality than [subtle] (it's a character
  /// conversation, not a form), but must still stay out of the way of the
  /// chat itself — a "quiet futuristic environment", not a space scene.
  mentor,
}

/// One row of tunable knobs per [BackgroundIntensity]. Centralizing these
/// here means intensity can be retuned app-wide from a single place instead
/// of hunting down hardcoded `darken:`/`starCount:` values scattered across
/// screens.
@immutable
class BackgroundPreset {
  const BackgroundPreset({
    required this.darken,
    required this.desaturation,
    required this.nebulaOpacity,
    required this.starCount,
    required this.starOpacityScale,
    required this.glowOpacity,
    required this.driftAmplitude,
    required this.driftDuration,
    required this.twinkleDuration,
  });

  /// 0-1 black readability overlay strength painted over the nebula.
  final double darken;

  /// 0-1 how far the nebula's colors are pulled toward grayscale.
  final double desaturation;

  /// 0-1 opacity of the nebula image layer itself.
  final double nebulaOpacity;

  /// Particle (star) count — the clearest lever on visual "busyness".
  final int starCount;

  /// Multiplier applied to each star's twinkle opacity range.
  final double starOpacityScale;

  /// 0-1 opacity of the single localized ambient-glow light source.
  /// 0 disables the layer entirely (used by `focus`).
  final double glowOpacity;

  /// Multiplier on the Ken-Burns pan/zoom distance. 1.0 = original amount.
  final double driftAmplitude;

  /// Slower duration reads as calmer even at the same amplitude.
  final Duration driftDuration;
  final Duration twinkleDuration;
}

/// Centralized preset table — see [BackgroundIntensity] for what each mode
/// is for. Tune the whole app's background feel from here.
abstract final class BackgroundPresets {
  static const Map<BackgroundIntensity, BackgroundPreset> all = {
    BackgroundIntensity.immersive: BackgroundPreset(
      darken: 0.42,
      desaturation: 0.12,
      nebulaOpacity: 1.0,
      starCount: 60,
      starOpacityScale: 1.0,
      glowOpacity: 0.14,
      driftAmplitude: 1.0,
      driftDuration: Duration(seconds: 26),
      twinkleDuration: Duration(seconds: 5),
    ),
    BackgroundIntensity.balanced: BackgroundPreset(
      darken: 0.52,
      desaturation: 0.24,
      nebulaOpacity: 0.88,
      starCount: 46,
      starOpacityScale: 0.85,
      glowOpacity: 0.09,
      driftAmplitude: 0.7,
      driftDuration: Duration(seconds: 32),
      twinkleDuration: Duration(seconds: 6),
    ),
    BackgroundIntensity.subtle: BackgroundPreset(
      darken: 0.68,
      desaturation: 0.46,
      nebulaOpacity: 0.6,
      starCount: 22,
      starOpacityScale: 0.55,
      glowOpacity: 0.05,
      driftAmplitude: 0.35,
      driftDuration: Duration(seconds: 46),
      twinkleDuration: Duration(seconds: 8),
    ),
    BackgroundIntensity.focus: BackgroundPreset(
      darken: 0.8,
      desaturation: 0.65,
      nebulaOpacity: 0.38,
      starCount: 8,
      starOpacityScale: 0.3,
      glowOpacity: 0.0,
      driftAmplitude: 0.12,
      driftDuration: Duration(seconds: 70),
      twinkleDuration: Duration(seconds: 10),
    ),
    BackgroundIntensity.mentor: BackgroundPreset(
      darken: 0.62,
      desaturation: 0.38,
      nebulaOpacity: 0.7,
      starCount: 30,
      starOpacityScale: 0.65,
      glowOpacity: 0.1,
      driftAmplitude: 0.4,
      driftDuration: Duration(seconds: 40),
      twinkleDuration: Duration(seconds: 7),
    ),
  };

  static BackgroundPreset resolve(BackgroundIntensity intensity) => all[intensity]!;
}
