import 'package:flutter/material.dart';

/// Tweens smoothly from the previous numeric value to [value] whenever it
/// changes (e.g. after a pull-to-refresh brings back a new current price),
/// rather than snapping — used by every hero card's headline figure.
class AnimatedValue extends StatelessWidget {
  const AnimatedValue({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 700),
  });

  final double value;
  final Widget Function(BuildContext, double) builder;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) => builder(context, animatedValue),
    );
  }
}
