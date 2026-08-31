import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists when each [PetMessage.id] (see
/// `features/pet/presentation/companion/pet_message.dart`) was last shown,
/// so `PetCompanionController` can honor a cooldown across app restarts
/// instead of re-nagging the user with the same nudge every cold start.
/// Local-only (SharedPreferences), mirroring [PetPreferencesRepository]'s
/// style — this is UI presentation memory, not gamification state, so it
/// has no backend counterpart.
class PetCompanionPreferencesRepository {
  static const _lastShownKey = 'pet_companion_last_shown';

  Future<Map<String, DateTime>> loadLastShown() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastShownKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (id, iso) => MapEntry(id, DateTime.parse(iso as String)),
      );
    } catch (_) {
      // Corrupted/old-format value — treat as no history rather than crash.
      return {};
    }
  }

  Future<void> recordShown(String id, DateTime at) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadLastShown();
    current[id] = at;
    final encoded = jsonEncode(
      current.map((id, at) => MapEntry(id, at.toIso8601String())),
    );
    await prefs.setString(_lastShownKey, encoded);
  }
}
