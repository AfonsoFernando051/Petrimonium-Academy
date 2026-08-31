import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/unavailable_badge.dart';

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  /// `false` means this action isn't implemented yet — the entry renders
  /// faded, carries an [UnavailableBadge] instead of the usual chevron, and
  /// its hit-testing is actually disabled (not just styled to look
  /// disabled), so tapping it can never silently do nothing.
  final bool available;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.available = true,
  });
}

/// Expandable speed-dial FAB for the Portfolio screen's quick actions.
class QuickActionsFab extends StatefulWidget {
  const QuickActionsFab({
    super.key,
    required this.onBuy,
    required this.onSell,
    required this.onRebalance,
    required this.onReports,
  });

  final VoidCallback onBuy;
  final VoidCallback onSell;
  final VoidCallback onRebalance;
  final VoidCallback onReports;

  @override
  State<QuickActionsFab> createState() => _QuickActionsFabState();
}

class _QuickActionsFabState extends State<QuickActionsFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  bool _open = false;

  late final List<_QuickAction> _actions = [
    _QuickAction(icon: Icons.add_chart, label: 'Investir', color: AppColors.neonViolet, onTap: widget.onBuy),
    _QuickAction(
      icon: Icons.sell_outlined,
      label: 'Vender',
      color: AppColors.negativeRed,
      onTap: widget.onSell,
      available: false,
    ),
    _QuickAction(
      icon: Icons.pie_chart_outline_rounded,
      label: 'Ver Alocação',
      color: AppColors.neonCyan,
      onTap: widget.onRebalance,
    ),
    _QuickAction(
      icon: Icons.insert_chart_outlined,
      label: 'Relatórios',
      color: AppColors.neonPurple,
      onTap: widget.onReports,
      available: false,
    ),
  ];

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() => _open = !_open);
    _open ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = _actions.length - 1; i >= 0; i--)
          _buildActionEntry(context, _actions[i], i),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'portfolio_quick_actions',
          backgroundColor: AppColors.neonViolet,
          onPressed: _toggle,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 260),
            turns: _open ? 0.125 : 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildActionEntry(BuildContext context, _QuickAction action, int index) {
    final tokens = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delayStart = index * 0.08;
        final t = ((_controller.value - delayStart) / (1 - delayStart)).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: child,
            ),
          ),
        );
      },
      child: IgnorePointer(
        // Two independent reasons to ignore taps: the speed-dial is closed,
        // or this specific action isn't implemented yet — either way,
        // nothing under here should be hit-testable.
        ignoring: !_open || !action.available,
        child: Semantics(
          button: true,
          enabled: action.available,
          label: action.available
              ? action.label
              : '${action.label}. ${Translator.translate(AppStrings.labComingSoon)}',
          child: Opacity(
            opacity: action.available ? 1 : UnavailableBadge.opacity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated.withValues(alpha: context.isDarkMode ? 0.85 : 0.96),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: action.color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(action.label, style: TextStyle(color: tokens.textPrimary, fontSize: 12)),
                      if (!action.available) ...[
                        const SizedBox(width: 6),
                        const UnavailableBadge(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.small(
                  heroTag: 'portfolio_action_${action.label}',
                  backgroundColor: action.color,
                  onPressed: !action.available
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          setState(() => _open = false);
                          _controller.reverse();
                          action.onTap();
                        },
                  child: Icon(action.icon, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
