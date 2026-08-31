import 'package:shared_preferences/shared_preferences.dart';

import 'package:petrimonium/core/utils/user_scoped_prefs.dart';

/// Persists completed Academy lesson ids on-device. Mirrors
/// `AchievementsLocalRepository`'s style exactly: entries are only ever
/// added, never removed — completing a lesson is permanent, like unlocking
/// an achievement.
///
/// Every key is scoped to the currently logged-in account (see
/// [UserScopedPrefs]) — switching accounts on the same device must never
/// show one user's local progress as another's. A device that already has
/// data under the old, unscoped key names (from before this scoping was
/// added) has it migrated, once, onto the current account's scoped key the
/// first time it's read — see [_migrateStringList]/[_migrateInt].
class AcademyProgressLocalRepository {
  static const _completedLessonIdsKey = 'academy_completed_lesson_ids';
  static const _perfectLessonIdsKey = 'academy_perfect_lesson_ids';
  static const _pendingSyncLessonIdsKey = 'academy_pending_sync_lesson_ids';
  static const _completedSimulatorIdsKey = 'academy_completed_simulator_ids';
  static const _pendingSyncSimulatorIdsKey =
      'academy_pending_sync_simulator_ids';

  Future<Set<String>> loadCompletedLessonIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _migrateStringList(prefs, _completedLessonIdsKey);
    return (prefs.getStringList(key) ?? const []).toSet();
  }

  /// Lesson ids completed with every question answered correctly on the
  /// first try — the raw signal `MasteryCalculator` scores against. A subset
  /// of [loadCompletedLessonIds]'s result by construction.
  Future<Set<String>> loadPerfectLessonIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _migrateStringList(prefs, _perfectLessonIdsKey);
    return (prefs.getStringList(key) ?? const []).toSet();
  }

  /// Marks [lessonId] as answered perfectly. Monotonic like
  /// [markLessonCompleted] — once perfect, always perfect, even if a later
  /// replay is missed — so Mastery can only improve via replay, never
  /// regress, matching this repository's existing "permanent, like unlocking
  /// an achievement" semantics.
  Future<Set<String>> markLessonPerfect(String lessonId) async {
    final existing = await loadPerfectLessonIds();
    if (existing.contains(lessonId)) return existing;

    final merged = {...existing, lessonId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(await UserScopedPrefs.key(_perfectLessonIdsKey), merged.toList());
    return merged;
  }

  /// Adds [lessonId] to whatever was already persisted. A no-op if the
  /// lesson was already completed (replaying a lesson never re-grants XP).
  Future<Set<String>> markLessonCompleted(String lessonId) async {
    final existing = await loadCompletedLessonIds();
    if (existing.contains(lessonId)) return existing;

    final merged = {...existing, lessonId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(await UserScopedPrefs.key(_completedLessonIdsKey), merged.toList());
    return merged;
  }

  /// Unions [serverLessonIds] into local storage — the same "only ever add,
  /// never remove" semantics as [markLessonCompleted]. Used to reconcile
  /// progress reported by the backend (e.g. completed on another device)
  /// without ever hiding a lesson completed locally but not yet synced.
  Future<Set<String>> mergeCompletedLessonIds(Set<String> serverLessonIds) async {
    final existing = await loadCompletedLessonIds();
    final merged = {...existing, ...serverLessonIds};
    if (merged.length == existing.length) return existing;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(await UserScopedPrefs.key(_completedLessonIdsKey), merged.toList());
    return merged;
  }

  /// A lightweight "recently struggling with this school" counter, used only
  /// to power the pet's difficulty-detected nudge (see
  /// `LessonSessionController`/`PetMessageCatalog.difficultyDetected`) — not
  /// a mistake-history log, no per-question detail is kept. Increments on
  /// every wrong answer in [schoolId] and resets on the next lesson
  /// completed there ([resetMisses]), so the signal only ever reflects
  /// recent struggle, not a permanent record.
  Future<int> recordMiss(String schoolId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _migrateInt(prefs, _missCountKey(schoolId));
    final updated = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, updated);
    return updated;
  }

  Future<void> resetMisses(String schoolId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _migrateInt(prefs, _missCountKey(schoolId));
    await prefs.remove(key);
  }

  String _missCountKey(String schoolId) => 'academy_miss_count_$schoolId';

  /// Lesson ids completed locally whose XP has not been confirmed synced to the backend yet
  /// (the initial POST failed or the app never got a chance to try, e.g. completed while
  /// offline). [AcademyController.load] retries these on every app start/reconciliation —
  /// see [markPendingSync]/[clearPendingSync].
  Future<Set<String>> loadPendingSyncLessonIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _migrateStringList(prefs, _pendingSyncLessonIdsKey);
    return (prefs.getStringList(key) ?? const []).toSet();
  }

  /// Recorded as soon as a lesson completes locally, before the sync attempt — so if the app
  /// is killed mid-request, the completion is still known to need a retry later.
  Future<void> markPendingSync(String lessonId) async {
    final existing = await loadPendingSyncLessonIds();
    if (existing.contains(lessonId)) return;

    final merged = {...existing, lessonId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(await UserScopedPrefs.key(_pendingSyncLessonIdsKey), merged.toList());
  }

  /// Removed once the backend has confirmed the completion (an initial sync or a retry).
  Future<void> clearPendingSync(String lessonId) async {
    final existing = await loadPendingSyncLessonIds();
    if (!existing.contains(lessonId)) return;

    final updated = {...existing}..remove(lessonId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(await UserScopedPrefs.key(_pendingSyncLessonIdsKey), updated.toList());
  }

  // ── Financial Lab simulator completions (DECISION-037) ──────────────────
  // Same shape as the lesson-completion trio above: only-ever-add local
  // storage, a merge for server reconciliation, and a pending-sync set for
  // offline/killed-app resilience.

  Future<Set<String>> loadCompletedSimulatorIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _migrateStringList(prefs, _completedSimulatorIdsKey);
    return (prefs.getStringList(key) ?? const []).toSet();
  }

  /// Adds [simulatorId] to whatever was already persisted. A no-op if the
  /// simulator was already completed (replaying it never re-grants XP).
  Future<Set<String>> markSimulatorCompleted(String simulatorId) async {
    final existing = await loadCompletedSimulatorIds();
    if (existing.contains(simulatorId)) return existing;

    final merged = {...existing, simulatorId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      await UserScopedPrefs.key(_completedSimulatorIdsKey),
      merged.toList(),
    );
    return merged;
  }

  /// Unions [serverSimulatorIds] into local storage — reconciles progress
  /// reported by the backend (e.g. completed on another device) without
  /// ever hiding a simulator completed locally but not yet synced.
  Future<Set<String>> mergeCompletedSimulatorIds(
    Set<String> serverSimulatorIds,
  ) async {
    final existing = await loadCompletedSimulatorIds();
    final merged = {...existing, ...serverSimulatorIds};
    if (merged.length == existing.length) return existing;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      await UserScopedPrefs.key(_completedSimulatorIdsKey),
      merged.toList(),
    );
    return merged;
  }

  Future<Set<String>> loadPendingSyncSimulatorIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _migrateStringList(prefs, _pendingSyncSimulatorIdsKey);
    return (prefs.getStringList(key) ?? const []).toSet();
  }

  /// Recorded as soon as a simulator completes locally, before the sync
  /// attempt — so if the app is killed mid-request, the completion is still
  /// known to need a retry later.
  Future<void> markSimulatorPendingSync(String simulatorId) async {
    final existing = await loadPendingSyncSimulatorIds();
    if (existing.contains(simulatorId)) return;

    final merged = {...existing, simulatorId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      await UserScopedPrefs.key(_pendingSyncSimulatorIdsKey),
      merged.toList(),
    );
  }

  /// Removed once the backend has confirmed the completion (an initial sync
  /// or a retry).
  Future<void> clearSimulatorPendingSync(String simulatorId) async {
    final existing = await loadPendingSyncSimulatorIds();
    if (!existing.contains(simulatorId)) return;

    final updated = {...existing}..remove(simulatorId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      await UserScopedPrefs.key(_pendingSyncSimulatorIdsKey),
      updated.toList(),
    );
  }

  /// Returns [baseKey]'s scoped form, first copying over any data still
  /// sitting under the old unscoped key (a device that hasn't read this key
  /// since scoping was introduced) so an existing single-account install
  /// doesn't appear to lose its progress. A no-op once the scoped key has
  /// been written at least once.
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

  /// Same migration as [_migrateStringList], for the int-valued miss-count keys.
  Future<String> _migrateInt(SharedPreferences prefs, String baseKey) async {
    final scopedKey = await UserScopedPrefs.key(baseKey);
    if (!prefs.containsKey(scopedKey)) {
      final legacy = prefs.getInt(baseKey);
      if (legacy != null) {
        await prefs.setInt(scopedKey, legacy);
        await prefs.remove(baseKey);
      }
    }
    return scopedKey;
  }
}
