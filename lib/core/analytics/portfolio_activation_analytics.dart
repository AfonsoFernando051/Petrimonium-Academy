import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal, local-only event log for the Portfolio Activation funnel. There
/// is no analytics service anywhere else in this app to extend — this is
/// deliberately scoped to this one feature rather than standing up a
/// general-purpose analytics system nothing else uses yet. Mirrors the
/// "static class + best-effort `SharedPreferences`" shape already used by
/// `Translator`/`OnboardingStateRepository`.
class PortfolioActivationAnalytics {
  PortfolioActivationAnalytics._();

  static const _eventsKey = 'portfolio_activation_analytics_events';
  static const _maxStoredEvents = 200;

  static Future<void> log(
    String event, {
    Map<String, String> params = const {},
  }) async {
    debugPrint('[analytics] $event $params');
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_eventsKey) ?? [];
      stored.add(
        jsonEncode({
          'event': event,
          'params': params,
          'at': DateTime.now().toIso8601String(),
        }),
      );
      final trimmed = stored.length > _maxStoredEvents
          ? stored.sublist(stored.length - _maxStoredEvents)
          : stored;
      await prefs.setStringList(_eventsKey, trimmed);
    } catch (_) {
      // Best-effort only — losing the local log is never worth surfacing to the user.
    }
  }
}
