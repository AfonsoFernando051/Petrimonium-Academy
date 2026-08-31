import 'package:flutter/foundation.dart';
import 'package:petrimonium/features/settings/data/datasources/settings_remote_datasource.dart';

class SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepository({required this.remoteDataSource});

  Future<String> getLanguage() => remoteDataSource.getLanguage();

  /// Persists the language preference server-side. Failures are swallowed —
  /// the local preference (already saved via Translator.setLanguage) remains
  /// the source of truth for the current session, so a network hiccup
  /// shouldn't block the user from using the app in their chosen language.
  Future<void> syncLanguage(String language) async {
    try {
      await remoteDataSource.updateLanguage(language);
    } catch (e) {
      debugPrint('WARN: failed to sync language preference with backend: $e');
    }
  }
}
