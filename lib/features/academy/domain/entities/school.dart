import 'package:flutter/material.dart';

/// A themed group of [AcademyModule]s (e.g. "Financial Life", "Fixed
/// Income") — the top level of the Academy curriculum. Mirrors
/// [AcademyModule]'s shape exactly: [contentAvailable] distinguishes real,
/// navigable schools from curriculum placeholders shown as "coming soon",
/// and [prerequisites] (school ids) gate a school behind others being
/// completed first. A school with no [prerequisites] is available as soon as
/// it has [contentAvailable] modules — existing schools never gain a new
/// prerequisite that would retroactively lock content a user can already
/// reach today.
class School {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int order;
  final List<String> prerequisites;
  final bool contentAvailable;

  const School({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    this.prerequisites = const [],
    this.contentAvailable = false,
  });
}
