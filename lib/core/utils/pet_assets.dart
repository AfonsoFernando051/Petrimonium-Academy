/// Resolves a pet species to its portrait asset. The single source of truth
/// for the `assets/images/generated_{specie}.png` naming convention — before
/// this existed, every screen that shows the pet's avatar rebuilt this path
/// (and its fallback) independently, so adding a species meant remembering
/// to update all of them.
class PetAssets {
  PetAssets._();

  static const String defaultSpecie = 'dog';

  /// [specie] is matched case-insensitively (backend/local values are
  /// sometimes `DOG`, sometimes `dog`). Falls back to [defaultSpecie] when
  /// `null`/blank, so callers always get a valid asset path.
  static String imageFor(String? specie) {
    final normalized = (specie == null || specie.trim().isEmpty) ? defaultSpecie : specie.trim().toLowerCase();
    return 'assets/images/generated_$normalized.png';
  }
}
