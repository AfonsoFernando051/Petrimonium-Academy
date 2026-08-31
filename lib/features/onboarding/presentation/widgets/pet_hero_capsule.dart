import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';

/// A glowing circular "platform" the pet stands on — the breathing/floating
/// composition originally hand-built once inside `PetConfigurationScreen`
/// (radial gradient ring, dual soft glow, slow scale+float animation),
/// promoted to a shared widget so every onboarding screen that puts the pet
/// center-stage (Welcome, Meet Pet, Gamification, Journey Ready) gets the
/// same premium "hero" treatment instead of a one-off copy per screen.
///
/// [child] is whatever should render inside the capsule — a plain portrait
/// `Image.asset` before the pet is configured, or `PetMascotWidget` once a
/// real species/evolution state exists.
class PetHeroCapsule extends StatefulWidget {
  const PetHeroCapsule({
    super.key,
    required this.child,
    this.size = 250,
    this.auraColor = AppColors.neonCyan,
    this.secondaryAuraColor = AppColors.neonPink,
  });

  final Widget child;
  final double size;
  final Color auraColor;
  final Color secondaryAuraColor;

  @override
  State<PetHeroCapsule> createState() => _PetHeroCapsuleState();
}

class _PetHeroCapsuleState extends State<PetHeroCapsule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  late final Animation<double> _breathe = Tween<double>(
    begin: 0.98,
    end: 1.02,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  late final Animation<double> _float = Tween<double>(
    begin: -5.0,
    end: 5.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: Transform.scale(scale: _breathe.value, child: child),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.auraColor.withValues(alpha: 0.18),
              AppColors.spaceDark.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: widget.auraColor.withValues(alpha: 0.22),
              blurRadius: 46,
              spreadRadius: 12,
            ),
            BoxShadow(
              color: widget.secondaryAuraColor.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 6,
            ),
          ],
        ),
        padding: EdgeInsets.all(widget.size * 0.08),
        child: widget.child,
      ),
    );
  }
}
