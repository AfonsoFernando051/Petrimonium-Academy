import 'dart:math';
import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// The app's shared background — a flat gradient plus a sparse, gently
/// twinkling starfield, matching the Academy design system exactly ("Base:
/// fundo cósmico escuro (#0A0A1A → #1A0B2E em gradiente), estrelas sutis de
/// fundo", Notion — Petrimonium Academy Onboarding Design). No nebula image,
/// Ken-Burns drift, or ambient glow blob: those belonged to an earlier, more
/// decorative direction — the mockups show a static, uniform background
/// behind every screen, with only a handful of subtle stars, not a busy
/// animated space scene.
class CosmicBackground extends StatefulWidget {
  const CosmicBackground({super.key, required this.child});

  final Widget child;

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with SingleTickerProviderStateMixin {
  static const int _starCount = 18;

  late final AnimationController _twinkleController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  late final List<_Star> _stars = _generateStars(_starCount);

  static List<_Star> _generateStars(int count) {
    final random = Random(7); // fixed seed: stable layout across rebuilds
    return List.generate(count, (_) {
      return _Star(
        dx: random.nextDouble(),
        dy: random.nextDouble(),
        radius: 0.6 + random.nextDouble() * 1.2,
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
    if (MediaQuery.of(context).disableAnimations) {
      _twinkleController.stop();
    } else if (!_twinkleController.isAnimating) {
      _twinkleController.repeat();
    }
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    if (!context.isDarkMode) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tokens.backgroundPrimary, tokens.backgroundSecondary],
          ),
        ),
        child: widget.child,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.spaceDark, AppColors.spacePurple],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _twinkleController,
          builder: (context, _) => CustomPaint(painter: _StarfieldPainter(stars: _stars, t: _twinkleController.value)),
        ),
        widget.child,
      ],
    );
  }
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
  _StarfieldPainter({required this.stars, required this.t});

  final List<_Star> stars;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      final cycle = (t * star.speed + star.phase) % 1.0;
      final twinkle = (sin(cycle * 2 * pi) + 1) / 2; // 0..1
      final opacity = (0.15 + twinkle * 0.45).clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => oldDelegate.t != t;
}
