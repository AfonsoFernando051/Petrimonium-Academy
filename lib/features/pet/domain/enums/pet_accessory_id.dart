import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';

/// Every cosmetic item unlockable via gamification rewards, grouped by the
/// [AccessoryType] slot it occupies.
enum PetAccessoryId {
  // Headwear
  baseballCap(AccessoryType.headwear),
  wizardHat(AccessoryType.headwear),
  spaceHelmet(AccessoryType.headwear),
  goldenCrown(AccessoryType.headwear),

  // Eyewear
  smartGlasses(AccessoryType.eyewear),
  sunglasses(AccessoryType.eyewear),

  // Neck / Back
  bowTie(AccessoryType.neckBack),
  scarf(AccessoryType.neckBack),
  headphones(AccessoryType.neckBack),
  backpack(AccessoryType.neckBack),
  angelWings(AccessoryType.neckBack),
  heroCape(AccessoryType.neckBack);

  const PetAccessoryId(this.slot);

  /// The slot this accessory occupies. Equipping it replaces whatever was
  /// previously equipped in the same slot.
  final AccessoryType slot;

  /// File name (without extension) used to look up the overlay asset under
  /// `assets/mascot/accessories/`.
  String get assetKey => name;
}
