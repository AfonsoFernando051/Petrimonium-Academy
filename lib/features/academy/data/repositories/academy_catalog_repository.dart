import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/network/api_error_parser.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level (not a method) so [compute] can run it on a background isolate —
/// decoding the full curriculum (hundreds of lessons/steps) on the UI isolate
/// would jank/freeze the app while the Academy screen opens.
AcademyCatalogSnapshot _parseAcademyCatalog(String rawJson) {
  return AcademyCatalogSnapshot.fromJson(
    jsonDecode(rawJson) as Map<String, dynamic>,
  );
}

/// Fetches the Academy catalog from the backend and caches it locally, one
/// entry per language — the backend is the source of truth (see
/// `docs/DECISIONS.md`), and the cache exists purely so the app can render
/// instantly from the last-known snapshot and work offline after a first
/// successful fetch. The raw response body is cached verbatim (not the
/// re-serialized model), so a cache round-trip is byte-identical to what
/// the backend actually sent.
class AcademyCatalogRepository {
  AcademyCatalogRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  static String _cacheKey(String lang) => 'academy_catalog_cache_$lang';

  /// The last snapshot fetched for [lang], if any — instantaneous, no
  /// network. `null` means this language has never been fetched
  /// successfully on this device, or the cached body no longer parses (e.g.
  /// it was written by a since-changed backend contract) — either way,
  /// `_loadCatalog` treats that identically to no cache and falls through to
  /// a fresh fetch, which then overwrites the bad entry. A parse failure
  /// must never propagate and crash the caller, since this is purely an
  /// optimization over the network fetch that always follows it.
  Future<AcademyCatalogSnapshot?> loadCached(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(lang));
    if (raw == null) return null;
    try {
      final snapshot = await compute(_parseAcademyCatalog, raw);
      // Older app versions could persist a response that had schools/lessons
      // but no domains. It parses successfully, yet the Academy home cannot
      // render it; treat it exactly like a broken cache so a fresh request
      // can recover the real curriculum.
      return _isEmptyCatalog(snapshot) ? null : snapshot;
    } catch (_) {
      return null;
    }
  }

  /// Fetches [lang]'s catalog from the backend and overwrites its cache
  /// entry. Throws on any network/HTTP failure — callers decide what to do
  /// with a stale-but-present cache vs. no cache at all (see
  /// `AcademyController.load`).
  Future<AcademyCatalogSnapshot> fetchAndCache(String lang) async {
    final response = await _apiClient.get(
      '${ApiConstants.academyCatalogEndpoint}?lang=$lang',
    );
    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback:
              'Failed to load academy catalog. Status Code: ${response.statusCode}',
        ),
      );
    }

    // Parse and validate before replacing a working cache. A backend that is
    // temporarily starting up can answer 200 with an empty document; caching
    // that response used to make the Academy appear to have disappeared until
    // the next successful fetch.
    final snapshot = await compute(_parseAcademyCatalog, response.body);
    if (_isEmptyCatalog(snapshot)) {
      throw const FormatException('Academy catalog returned no content.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey(lang), response.body);
    return snapshot;
  }

  /// The Academy home screen is organized by domains. A payload without them
  /// cannot render any curriculum, even if it happens to contain orphaned
  /// schools or lessons, so it must never replace a usable cache.
  ///
  /// A catalog with available modules but no available schools is also
  /// inconsistent: modules cannot be reached while their parent schools are
  /// marked unavailable. Older backend seeds produced exactly that shape, so
  /// discard it and let the next successful request replace the stale cache.
  static bool _isEmptyCatalog(AcademyCatalogSnapshot snapshot) {
    if (snapshot.domains.isEmpty) return true;

    final hasAvailableModule = snapshot.modules.any(
      (module) => module.contentAvailable,
    );
    final hasAvailableSchool = snapshot.schools.any(
      (school) => school.contentAvailable,
    );
    return hasAvailableModule && !hasAvailableSchool;
  }
}
