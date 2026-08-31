import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/insight.dart';
import 'package:petrimonium/features/portfolio/domain/enums/insight_priority.dart';

class InsightCardWidget extends StatelessWidget {
  const InsightCardWidget({super.key, required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: insight.color.withValues(alpha: 0.35),
      borderRadius: 16,
      borderWidth: 1,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(insight.icon, color: insight.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          insight.title,
                          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      if (insight.priority == InsightPriority.high) _priorityDot(context),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(insight.description, style: TextStyle(color: tokens.textSecondary, fontSize: 12, height: 1.35)),
                  if (insight.actionLabel != null && insight.onAction != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: insight.onAction,
                      child: Text(
                        '${insight.actionLabel} →',
                        style: TextStyle(color: insight.color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityDot(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(left: 6, top: 4),
      decoration: BoxDecoration(color: context.colors.error, shape: BoxShape.circle),
    );
  }
}
