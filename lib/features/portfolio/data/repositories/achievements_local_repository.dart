import 'package:shared_preferences/shared_preferences.dart';

import 'package:petrimonium/core/utils/user_scoped_prefs.dart';

/// A local, offline-fallback cache of unlocked achievement ids + their
/// unlock timestamp. The backend (`AchievementsRepository.evaluate()`) is
/// now the source of truth — every successful evaluation overwrites this
/// cache with the server's authoritative state via [cacheUnlocked]. This
/// class only exists so the UI has something real to show if the app opens
/// offline; it never decides what's unlocked on its own.
///
/// Both keys are scoped to the currently logged-in account (see
/// [UserScopedPrefs]) — switching accounts on the same device must never
/// show one user's cached achievements as another's while offline. A device
/// that already has data under the old, unscoped key names is migrated onto
/// the current account's scoped keys the first time it's read.
class AchievementsLocalRepository {
  static const _idsKey = 'achievements_unlocked_ids';
  static const _datesKey = 'achievements_unlocked_dates';

  Future<Map<String, DateTime>> loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final idsKey = await _migrateStringList(prefs, _idsKey);
    final datesKey = await _migrateStringList(prefs, _datesKey);
    final ids = prefs.getStringList(idsKey) ?? const [];
    final dates = prefs.getStringList(datesKey) ?? const [];

    final result = <String, DateTime>{};
    for (var i = 0; i < ids.length && i < dates.length; i++) {
      final parsed = DateTime.tryParse(dates[i]);
      if (parsed != null) result[ids[i]] = parsed;
    }
    return result;
  }

  /// Overwrites the local cache with the backend's authoritative unlocked
  /// map. Safe as a plain overwrite (not a merge) because achievements are
  /// permanent — the server's set never shrinks.
  Future<void> cacheUnlocked(Map<String, DateTime> unlockedAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(await UserScopedPrefs.key(_idsKey), unlockedAt.keys.toList());
    await prefs.setStringList(
      await UserScopedPrefs.key(_datesKey),
      unlockedAt.values.map((d) => d.toIso8601String()).toList(),
    );
  }

  /// Returns [baseKey]'s scoped form, migrating over any data still sitting
  /// under the old unscoped key the first time it's read on this device —
  /// see `AcademyProgressLocalRepository._migrateStringList` for the same
  /// pattern and its rationale.
  Future<String> _migrateStringList(SharedPreferences prefs, String baseKey) async {
    final scopedKey = await UserScopedPrefs.key(baseKey);
    if (!prefs.containsKey(scopedKey)) {
      final legacy = prefs.getStringList(baseKey);
      if (legacy != null) {
        await prefs.setStringList(scopedKey, legacy);
        await prefs.remove(baseKey);
      }
    }
    return scopedKey;
  }
}
