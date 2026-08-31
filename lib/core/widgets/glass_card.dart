import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';

/// Light-mode surface hierarchy for [GlassCard] — Dark theme keeps its
/// single glow-border look regardless of [GlassCard.surface] (it already
/// reads as "premium" through the cosmic background + golden border, and
/// this refinement pass is Light-mode-scoped).
///
/// Ordered by visual weight, lightest to strongest: [standard] is the
/// default "just a card"; [elevated] steps up for content that deserves
/// more presence (a hero stat, a sheet); [active] marks "this is the
/// current/selected thing" with a brand-accent tint and glow; [reward]
/// is the golden/gradient-adjacent treatment for completed/celebratory
/// states; [disabled] recedes below [standard] for locked/inactive content.
enum CardSurface { standard, elevated, active, reward, disabled }

/// A real glassmorphism card with BackdropFilter blur.
/// All content placed on top of the nebula background will now correctly
/// show frosted-glass depth instead of a plain translucent rectangle.
///
/// Default background/border adapt to the active theme via `context.colors`
/// — pass explicit [backgroundColor]/[borderColor] only when a card needs a
/// specific per-feature accent (e.g. the pink companion card border), since
/// those accent hues are already theme-invariant (see [AppColors]). Explicit
/// [backgroundColor]/[borderColor]/[boxShadow] always win over [surface].
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final bool isAnimated;

  /// Where this card sits in the Light-mode surface hierarchy. No effect in
  /// Dark theme. See [CardSurface].
  final CardSurface surface;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = AppRadii.xxl,
    this.borderWidth = 1.5,
    this.boxShadow,
    this.isAnimated = false,
    this.surface = CardSurface.standard,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isDark = context.isDarkMode;
    final look = _resolveLook(tokens, isDark);

    final effectiveBg = backgroundColor ?? look.background;
    final effectiveBorder = borderColor ?? look.border;
    final effectiveShadow = boxShadow ?? look.shadow;
    final radius = BorderRadius.circular(borderRadius);

    // The shadow lives on an outer, unclipped Container — nesting it inside
    // the ClipRRect below (as the blurred Container's own decoration) would
    // clip it away entirely, since ClipRRect clips strictly to its bounds.
    final inner = Container(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: effectiveShadow),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: radius,
              border: Border.all(color: effectiveBorder, width: borderWidth),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (margin != null) {
      return Container(margin: margin, child: inner);
    }
    return inner;
  }

  _CardLook _resolveLook(AppColorTokens tokens, bool isDark) {
    if (isDark) {
      // Dark theme leans on the glowing border for depth; unaffected by
      // [surface] — see class doc.
      return _CardLook(background: tokens.surface.withValues(alpha: 0.55), border: AppColors.goldenBorder.withValues(alpha: 0.5));
    }

    switch (surface) {
      case CardSurface.standard:
        // Light theme has no glow to rely on, so it gets a soft,
        // barely-there elevation shadow instead (brief: "extremely soft
        // shadows", not heavy card shadows).
        return _CardLook(
          background: tokens.surface.withValues(alpha: 0.94),
          border: tokens.border,
          shadow: [BoxShadow(color: tokens.shadow, blurRadius: 18, offset: const Offset(0, 6))],
        );
      case CardSurface.elevated:
        return _CardLook(
          background: tokens.surfaceElevated,
          border: tokens.borderStrong,
          shadow: [BoxShadow(color: tokens.shadow.withValues(alpha: tokens.shadow.a * 1.6), blurRadius: 28, offset: const Offset(0, 10))],
        );
      case CardSurface.active:
        // "This is the current step" — a brand-purple tint and glow, not
        // just a stronger neutral shadow, so it reads as meaningfully
        // different from `elevated` rather than just "more of the same".
        return _CardLook(
          background: Color.alphaBlend(AppColors.neonPurple.withValues(alpha: 0.05), tokens.surfaceElevated),
          border: AppColors.neonPurple.withValues(alpha: 0.4),
          shadow: [BoxShadow(color: AppColors.neonPurple.withValues(alpha: 0.16), blurRadius: 22, offset: const Offset(0, 8))],
        );
      case CardSurface.reward:
        // Completed/celebratory — golden glow instead of purple, echoing
        // the brand gradient's warm end without tinting every card pink.
        return _CardLook(
          background: Color.alphaBlend(AppColors.goldenBorder.withValues(alpha: 0.06), tokens.surfaceElevated),
          border: AppColors.goldenBorder.withValues(alpha: 0.45),
          shadow: [BoxShadow(color: AppColors.goldenBorder.withValues(alpha: 0.18), blurRadius: 22, offset: const Offset(0, 8))],
        );
      case CardSurface.disabled:
        // Recedes below `standard` — muted surface, no shadow, so locked
        // content reads as "not here yet" without needing extra Opacity.
        return _CardLook(background: tokens.surfaceMuted, border: tokens.border, shadow: null);
    }
  }
}

class _CardLook {
  const _CardLook({required this.background, required this.border, this.shadow});

  final Color background;
  final Color border;
  final List<BoxShadow>? shadow;
}
