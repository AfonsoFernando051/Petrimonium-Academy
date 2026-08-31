import 'package:flutter/material.dart';

/// A themed group of [School]s (e.g. "Investimentos" grouping "Renda Fixa",
/// "Ações e Renda Variável", "Fundos, ETFs e FIIs", ...) — the top level of
/// the Academy catalog, one step above [School]. Purely a client-side
/// navigation/grouping concept (see `docs/DECISIONS.md` DECISION-019): it
/// does not own lessons or progress itself, only groups existing schools by
/// [schoolIds] — status and mastery are always derived from those member
/// schools (`AcademyProgressCalculator.domainStatus`,
/// `KnowledgeProgressCalculator.percentForDomain`), never stored here.
class AcademyDomain {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int order;
  final List<String> schoolIds;

  const AcademyDomain({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    this.schoolIds = const [],
  });
}
