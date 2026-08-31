import 'package:flutter/material.dart';
import 'package:petrimonium/features/portfolio/domain/entities/insight.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/insight_card_widget.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

class InsightsSection extends StatelessWidget {
  const InsightsSection({super.key, required this.insights});

  final List<Insight> insights;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('INSIGHTS DO PORTFÓLIO'),
        const SizedBox(height: 10),
        for (final insight in insights) InsightCardWidget(insight: insight),
      ],
    );
  }
}
