import 'dart:math';
import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/background_presets.dart';

/// The app's shared "living background". In Dark theme this is the original
/// nebula image with a slow Ken-Burns drift, a darken pass, a localized
/// ambient glow, and a twinkling starfield. Light theme swaps the space
/// imagery for a soft, bright aurora gradient with slow-drifting color blobs
/// — same "alive, not static wallpaper" feeling, without forcing a dark
/// space scene onto a bright, friendly theme. One widget, two looks — no
/// duplicated screens.
///
/// [intensity] is what makes the background context-aware: every knob
/// (readability overlay strength, particle density, glow, how much the
/// scene moves) is driven by a single [BackgroundPreset] looked up from
/// [BackgroundPresets] — see that file to retune the whole app's feel from
/// one place instead of hunting hardcoded values across screens. The rule
/// of thumb: the more cognitively demanding the screen, the quieter the
/// preset (`immersive` on Home → `focus` on a lesson/quiz).
///
/// [darken]/[starCount] remain as optional escape-hatch overrides for
/// screens with a bespoke mood (e.g. Login) that isn't one of the named
/// intensities.
class CosmicBackground extends StatefulWidget {
  const CosmicBackground({
    super.key,
    required this.child,
    this.intensity = BackgroundIntensity.balanced,
    this.assetPath = 'assets/images/bg_nebula.png',
    this.darken,
    this.starCount,
    this.errorBuilder,
    this.showArtworkInLightMode = false,
  });

  final Widget child;
  final String assetPath;

  /// Context-aware visual weight — see [BackgroundIntensity].
  final BackgroundIntensity intensity;

  /// Overrides the resolved preset's darken value when set. Dark theme only.
  final double? darken;

  /// Overrides the resolved preset's star count when set.
  final int? starCount;
  final ImageErrorWidgetBuilder? errorBuilder;

  /// When true, Light theme reuses [assetPath] (with a lightened, white-wash
  /// treatment) instead of the generic abstract aurora — for screens like
  /// Login where the artwork itself (not just ambient color) is the point.
  /// Defaults to false: most `CosmicBackground` call sites use the generic
  /// dark-space `bg_nebula.png`, which reads as heavy even lightened, so
  /// they keep the abstract aurora treatment instead.
  final bool showArtworkInLightMode;

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with TickerProviderStateMixin {
  late BackgroundPreset _preset = BackgroundPresets.resolve(widget.intensity);

  late final AnimationController _driftController = AnimationController(
    vsync: this,
    duration: _preset.driftDuration,
  );

  late final AnimationController _twinkleController = AnimationController(
    vsync: this,
    duration: _preset.twinkleDuration,
  );

  late List<_Star> _stars = _generateStars(_effectiveStarCount);

  bool? _reducedMotion;

  int get _effectiveStarCount => widget.starCount ?? _preset.starCount;
  double get _effectiveDarken => widget.darken ?? _preset.darken;

  static List<_Star> _generateStars(int count) {
    final random = Random(7); // fixed seed: stable layout across rebuilds
    return List.generate(count, (_) {
      return _Star(
        dx: random.nextDouble(),
        dy: random.nextDouble(),
        radius: 0.6 + random.nextDouble() * 1.4,
        phase: random.nextDouble(),
        speed: 0.6 + random.nextDouble() * 0.8,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Flutter's equivalent of CSS `prefers-reduced-motion`: driven by the
    // OS-level "Reduce Motion" accessibility setting.
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    if (reducedMotion != _reducedMotion) {
      _reducedMotion = reducedMotion;
      _syncAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant CosmicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Same widget/State can be reused across a background-intensity change
    // (e.g. the Dashboard's IndexedStack swapping tabs) — retune the live
    // controllers/particles instead of waiting for a full remount.
    if (oldWidget.intensity != widget.intensity) {
      _preset = BackgroundPresets.resolve(widget.intensity);
      _driftController.duration = _preset.driftDuration;
      _twinkleController.duration = _preset.twinkleDuration;
      _syncAnimation();
    }
    if (oldWidget.starCount != widget.starCount || oldWidget.intensity != widget.intensity) {
      _stars = _generateStars(_effectiveStarCount);
    }
  }

  void _syncAnimation() {
    final reduced = _reducedMotion ?? false;
    if (reduced) {
      _driftController.stop();
      _twinkleController.stop();
    } else {
      if (!_driftController.isAnimating) _driftController.repeat();
      if (!_twinkleController.isAnimating) _twinkleController.repeat();
    }
  }

  @override
  void dispose() {
    _driftController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  // Reduces color saturation by [amount] (0 = no change, 1 = grayscale) so
  // the background never competes with foreground glass cards for attention.
  static List<double> _desaturationMatrix(double amount) {
    const lumR = 0.2126, lumG = 0.7152, lumB = 0.0722;
    final s = 1 - amount;
    final sr = (1 - s) * lumR;
    final sg = (1 - s) * lumG;
    final sb = (1 - s) * lumB;
    return <double>[
      sr + s, sg, sb, 0, 0,
      sr, sg + s, sb, 0, 0,
      sr, sg, sb + s, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isDarkMode) {
      if (widget.showArtworkInLightMode) {
        return _LightImageBackground(
          driftController: _driftController,
          assetPath: widget.assetPath,
          errorBuilder: widget.errorBuilder,
          preset: _preset,
          child: widget.child,
        );
      }
      return _LightAuroraBackground(driftController: _driftController, preset: _preset, child: widget.child);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _driftController,
          builder: (context, child) {
            // Slow figure-eight-ish pan/scale — a Ken-Burns drift, scaled by
            // the preset's driftAmplitude so Focus/Subtle screens barely
            // move while Home keeps the full "alive" feeling.
            final t = _driftController.value * 2 * pi;
            final amp = _preset.driftAmplitude;
            final dx = sin(t) * 10 * amp;
            final dy = cos(t * 0.7) * 6 * amp;
            return Transform.scale(
              scale: 1.0 + 0.06 * amp,
              child: Transform.translate(offset: Offset(dx, dy), child: child),
            );
          },
          child: Opacity(
            opacity: _preset.nebulaOpacity,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(_desaturationMatrix(_preset.desaturation)),
              child: Image.asset(widget.assetPath, fit: BoxFit.cover, errorBuilder: widget.errorBuilder),
            ),
          ),
        ),
        if (_preset.glowOpacity > 0) _AmbientGlow(opacity: _preset.glowOpacity),
        Container(color: Colors.black.withValues(alpha: _effectiveDarken)),
        if (_effectiveStarCount > 0)
          AnimatedBuilder(
            animation: _twinkleController,
            builder: (context, _) => CustomPaint(
              painter: _StarfieldPainter(
                stars: _stars,
                t: _twinkleController.value,
                opacityScale: _preset.starOpacityScale,
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

/// Layer 4 — a single, static (unanimated, so effectively free) localized
/// light source in the upper field of the screen. Kept out of the lower/
/// center area where primary content and glass cards usually sit, so it
/// reads as ambient depth rather than a hotspot behind information.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.55, -0.75),
          radius: 0.9,
          colors: [AppColors.neonPurple.withValues(alpha: opacity), AppColors.neonPurple.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// Light theme's answer to the nebula: a soft pearl/lavender gradient with
/// large, heavily-blurred accent-tinted blobs drifting slowly behind the
/// content — "bright and alive", not "dark space scene lightened up". Built
/// from plain gradients (no BackdropFilter/blur passes) so it stays cheap to
/// repaint every frame. Blob count/opacity/drift scale with [preset] so the
/// same context-aware hierarchy applies in Light theme too.
class _LightAuroraBackground extends StatelessWidget {
  const _LightAuroraBackground({required this.driftController, required this.preset, required this.child});

  final AnimationController driftController;
  final BackgroundPreset preset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    // Quieter presets show fewer blobs at lower alpha instead of just a
    // flat opacity scale — keeps the "few soft light sources" look intact
    // rather than an evenly-faded wash.
    final visibleAnchors = preset.glowOpacity >= 0.09 ? 3 : (preset.glowOpacity > 0 ? 2 : 1);
    final alphaScale = (preset.nebulaOpacity).clamp(0.35, 1.0);
    // Richer presets (Home) get larger, more overlapping/blended blobs for
    // a genuine atmospheric wash; quieter presets (Academy/Lesson) pull
    // them tighter and smaller so they read as a few quiet light sources.
    final radiusScale = 0.34 + 0.12 * alphaScale;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // A faint warm-lavender middle stop instead of a flat 2-tone
              // fade — this is what keeps the page background from reading
              // as plain off-white while staying well under text contrast.
              colors: [
                tokens.backgroundPrimary,
                Color.alphaBlend(AppColors.neonPurple.withValues(alpha: 0.035), tokens.backgroundPrimary),
                tokens.backgroundSecondary,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: driftController,
          builder: (context, _) {
            final t = driftController.value * 2 * pi * preset.driftAmplitude.clamp(0.3, 1.0);
            return CustomPaint(
              painter: _AuroraPainter(
                t: t,
                anchorCount: visibleAnchors,
                radiusScale: radiusScale,
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.17 * alphaScale),
                  AppColors.neonPurple.withValues(alpha: 0.15 * alphaScale),
                  AppColors.neonPink.withValues(alpha: 0.10 * alphaScale),
                ],
              ),
            );
          },
        ),
        child,
      ],
    );
  }
}

/// Light-theme treatment for screens that want their own artwork as ambient
/// wallpaper (e.g. Login's fox-and-compass illustration) rather than the
/// generic aurora — same Ken-Burns drift as Dark theme's nebula, but a soft
/// white wash instead of a black darken pass, so the art reads as bright and
/// dreamy instead of heavy. No starfield: white twinkles would disappear
/// against a light wash.
class _LightImageBackground extends StatelessWidget {
  const _LightImageBackground({
    required this.driftController,
    required this.assetPath,
    required this.child,
    required this.preset,
    this.errorBuilder,
  });

  final AnimationController driftController;
  final String assetPath;
  final Widget child;
  final BackgroundPreset preset;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: tokens.backgroundPrimary),
        AnimatedBuilder(
          animation: driftController,
          builder: (context, child) {
            final t = driftController.value * 2 * pi;
            final amp = preset.driftAmplitude;
            final dx = sin(t) * 10 * amp;
            final dy = cos(t * 0.7) * 6 * amp;
            return Transform.scale(
              scale: 1.0 + 0.06 * amp,
              child: Transform.translate(offset: Offset(dx, dy), child: child),
            );
          },
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(_CosmicBackgroundState._desaturationMatrix(0.08)),
            child: Image.asset(assetPath, fit: BoxFit.cover, errorBuilder: errorBuilder),
          ),
        ),
        Container(color: tokens.backgroundPrimary.withValues(alpha: 0.62)),
        child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.t, required this.colors, this.anchorCount = 3, this.radiusScale = 0.42});

  final double t;
  final List<Color> colors;
  final int anchorCount;

  /// Fraction of `size.shortestSide` each blob's radius spans — richer
  /// presets use a larger value so blobs blend into one atmospheric wash.
  final double radiusScale;

  static const List<Offset> _anchors = [Offset(0.15, 0.12), Offset(0.85, 0.28), Offset(0.35, 0.85)];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < anchorCount && i < _anchors.length; i++) {
      final anchor = _anchors[i];
      final phase = t + i * (2 * pi / _anchors.length);
      final dx = anchor.dx * size.width + sin(phase) * size.width * 0.06;
      final dy = anchor.dy * size.height + cos(phase * 0.8) * size.height * 0.05;
      final radius = size.shortestSide * radiusScale;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [colors[i % colors.length], colors[i % colors.length].withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.anchorCount != anchorCount || oldDelegate.radiusScale != radiusScale;
}

class _Star {
  const _Star({required this.dx, required this.dy, required this.radius, required this.phase, required this.speed});

  final double dx;
  final double dy;
  final double radius;
  final double phase;
  final double speed;
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({required this.stars, required this.t, this.opacityScale = 1.0});

  final List<_Star> stars;
  final double t;
  final double opacityScale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      final cycle = (t * star.speed + star.phase) % 1.0;
      final twinkle = (sin(cycle * 2 * pi) + 1) / 2; // 0..1
      final opacity = ((0.15 + twinkle * 0.55) * opacityScale).clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.opacityScale != opacityScale;
}
