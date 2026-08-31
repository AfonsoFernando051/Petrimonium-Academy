/// Data freshness status for market-sensitive information.
///
/// Every asset details response carries a status so the UI can
/// communicate how current the displayed data is — never silently
/// presenting stale data as live.
enum AssetDataStatus {
  /// Just fetched from the provider.
  fresh,

  /// Returned from a local or backend cache; still within TTL.
  cached,

  /// The provider returns data with a known delay (e.g. 15 min).
  delayed,

  /// Some fields were populated but others were unavailable.
  partial,

  /// The provider could not be reached or returned an error.
  unavailable,

  /// An unexpected error occurred during data retrieval.
  error;

  static AssetDataStatus fromString(String? value) {
    if (value == null) return AssetDataStatus.unavailable;
    return AssetDataStatus.values.firstWhere(
      (s) => s.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AssetDataStatus.unavailable,
    );
  }
}
