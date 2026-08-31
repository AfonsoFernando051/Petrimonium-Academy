import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';

/// A premium "mobile-game" CTA button: gradient fill, ambient glow, a tap-down
/// press animation, and an optional slow idle pulse reserved for the single
/// most important action on a screen (per-screen restraint — pulsing every
/// button at once reads as noisy, not premium).
///
/// Reused across the app instead of one-off `ElevatedButton`s so every
/// primary CTA (login, quick actions, empty-state "invest now") shares the
/// same premium feel.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required String this.label,
    required this.onPressed,
    this.icon,
    this.colors = AppColors.brandGradient,
    this.pulse = false,
    this.isLoading = false,
    this.height = 56,
    this.borderRadius = AppRadii.xl,
    this.expand = true,
    this.iconTrailing = false,
  }) : child = null;

  /// Same gradient/glow/press/pulse chrome, but with fully custom content —
  /// for CTAs that need more than an icon+label (e.g. a title+subtitle quick
  /// action) without duplicating this widget's animation logic.
  ///
  /// [height] defaults to `null` here (content-sized) rather than the fixed
  /// 56 the label/icon mode uses — custom content's natural height varies
  /// (a single line vs. an icon+title+subtitle block), and a fixed height
  /// would either clip taller content or leave dead space around shorter
  /// content. `Center` gives its child loose constraints, so a too-small
  /// fixed height here would silently overflow rather than shrink content.
  const GameButton.custom({
    super.key,
    required Widget this.child,
    required this.onPressed,
    this.colors = AppColors.brandGradient,
    this.pulse = false,
    this.height,
    this.borderRadius = AppRadii.xl,
    this.expand = true,
  })  : label = null,
        icon = null,
        iconTrailing = false,
        isLoading = false;

  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconTrailing;
  final List<Color> colors;

  /// Reserve `true` for the single most important CTA on a screen.
  final bool pulse;
  final bool isLoading;
  final double? height;
  final double borderRadius;
  final bool expand;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final Animation<double> _pulseAnimation =
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

  late final AnimationController _pressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  // 1.0 at rest -> 0.94 while pressed. `_pressController` runs its default
  // [0, 1] range; the Tween maps that directly to the visual scale, so the
  // button is never briefly scaled to 0 (which would make it un-hit-testable
  // — `Transform.scale(scale: 0)` is a singular, non-invertible matrix).
  late final Animation<double> _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
    CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant GameButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !oldWidget.pulse) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.pulse && oldWidget.pulse) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails _) {
    if (!_enabled) return;
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_enabled) return;
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.colors.last;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _pressController]),
      builder: (context, child) {
        final pulseGlow = 14 + (_pulseAnimation.value * 10);
        final pulseSpread = 1 + (_pulseAnimation.value * 2);
        final scale = _pressScale.value;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: _enabled ? 1.0 : 0.5,
            child: Container(
              height: widget.height,
              width: widget.expand ? double.infinity : null,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.colors,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.55),
                    blurRadius: pulseGlow,
                    spreadRadius: pulseSpread,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.12),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          onTap: _enabled
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onPressed?.call();
                }
              : null,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: widget.child != null ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: widget.child ??
                  (widget.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null && !widget.iconTrailing) ...[
                              Icon(widget.icon, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                widget.label!,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.title.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            if (widget.icon != null && widget.iconTrailing) ...[
                              const SizedBox(width: 8),
                              Icon(widget.icon, color: Colors.white, size: 20),
                            ],
                          ],
                        )),
            ),
          ),
        ),
      ),
    );
  }
}
