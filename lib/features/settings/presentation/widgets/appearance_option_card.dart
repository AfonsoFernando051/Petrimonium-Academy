import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// One selectable row in the Appearance section: an icon "preview" swatch
/// previewing the option's own mood (not the app's current theme), a
/// title+description, and an animated selected state. Large tap target and
/// its own micro-animation on selection change, per the "smooth interaction"
/// requirement — separate from (and faster than) the app-wide theme
/// cross-fade this triggers.
class AppearanceOptionCard extends StatelessWidget {
  const AppearanceOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.swatchColors,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;

  /// Gradient colors used for this option's preview swatch — deliberately
  /// fixed regardless of the *active* app theme, since the swatch previews
  /// what that mode itself looks like.
  final List<Color> swatchColors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected ? tokens.primary.withValues(alpha: 0.10) : tokens.surface,
            border: Border.all(
              color: selected ? tokens.primary : tokens.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: swatchColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: swatchColors.last.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected
                    ? Icon(Icons.check_circle_rounded, key: const ValueKey('sel'), color: tokens.primary, size: 24)
                    : Icon(Icons.circle_outlined, key: const ValueKey('unsel'), color: tokens.border, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
