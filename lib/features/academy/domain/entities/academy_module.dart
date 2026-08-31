import 'package:flutter/material.dart';

/// A themed group of lessons (e.g. "Investor Foundations", "Fixed Income"),
/// belonging to one [School] (see [schoolId]).
/// [contentAvailable] distinguishes real, playable modules from curriculum
/// placeholders shown as "coming soon" — the progression system's full shape
/// is visible from day one without shipping unwritten content.
/// [prerequisites] (module ids) must all be completed before this module is
/// `available`, on top of its school's own unlock state — see
/// `AcademyProgressCalculator.moduleStatus`. Existing modules never gain a
/// new prerequisite that would retroactively lock content a user can already
/// reach today.
class AcademyModule {
  final String id;
  final String schoolId;
  final String title;
  final String description;
  final IconData icon;
  final int order;
  final List<String> lessonIds;
  final List<String> prerequisites;
  final bool contentAvailable;

  const AcademyModule({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    this.lessonIds = const [],
    this.prerequisites = const [],
    this.contentAvailable = false,
  });
}
