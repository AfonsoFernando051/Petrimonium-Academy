import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_accessory.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_evolution_rule.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';

/// After this many days without a session, the mascot rests in [sleep]
/// instead of its usual idle loop.
const int kSleepAfterInactiveDays = 3;

/// Local hours (0-23, device time) during which the mascot is considered to
/// be sleeping even on an active day.
const int kNightStartHour = 0;
const int kNightEndHour = 6;

/// Reactive state holder for the pet mascot: current [PetProfile], transient
/// event-driven animation overrides, and the financial-progress → evolution
/// mapping.
class MascotController extends ChangeNotifier {
  MascotController({
    required MascotRepository repository,
    List<PetEvolutionRule> evolutionRules = PetEvolutionRule.defaultRules,
    AppEventBus? eventBus,
  })  : _repository = repository,
        _rules = _sortedDescending(evolutionRules),
        _eventBus = eventBus ?? AppEventBus.instance,
        _profile = PetProfile();

  final MascotRepository _repository;
  final List<PetEvolutionRule> _rules;
  final AppEventBus _eventBus;

  PetProfile _profile;
  Timer? _revertTimer;
  bool _loading = false;
  bool _hasLoaded = false;
  int? _daysSinceLastSession;

  PetProfile get profile => _profile;
  PetAnimationState get animationState => _profile.animationState;
  PetEvolutionStage get stage => _profile.stage;
  bool get isLoading => _loading;

  /// Days elapsed between the previous session's [PetProfile.lastActiveAt]
  /// and the [loadProfile] call that just ran — `null` until the first
  /// [loadProfile] completes. Computed from the *old* `lastActiveAt`, before
  /// it's overwritten with "now" below, so it genuinely reflects the gap the
  /// user was away, not zero. Drives the pet companion's return-after-
  /// inactivity greeting (see `PetMessageCatalog._returnGreeting`) — a fresh
  /// profile's default `lastActiveAt` (≈ now) keeps this at 0 on a
  /// brand-new user's very first session, so it never misreads as "returning".
  int? get daysSinceLastSession => _daysSinceLastSession;

  /// Whether [loadProfile] has completed at least once, i.e. [profile]
  /// reflects real repository data rather than just the constructor's
  /// placeholder `PetProfile()` (species DOG). Consumers that key
  /// species-specific work off [profile] — [PetRiveCompanion] loading a
  /// `{specie}.riv` — should wait for this before acting, or they'll act on
  /// the placeholder species for the first frame regardless of what the
  /// player's pet actually is.
  bool get hasLoadedProfile => _hasLoaded;

  static List<PetEvolutionRule> _sortedDescending(List<PetEvolutionRule> rules) {
    final sorted = List<PetEvolutionRule>.of(rules);
    sorted.sort((a, b) => b.stage.tier.compareTo(a.stage.tier));
    return sorted;
  }

  /// Loads the persisted profile, resolves whether the mascot should be
  /// resting ([PetAnimationState.sleep]) based on inactivity, then records
  /// this session as "now".
  Future<void> loadProfile({DateTime? now}) async {
    _loading = true;
    notifyListeners();

    final loaded = await _repository.loadProfile();
    final currentTime = now ?? DateTime.now();
    _daysSinceLastSession = currentTime.difference(loaded.lastActiveAt).inDays;
    final restingState = restingStateFor(
      lastActiveAt: loaded.lastActiveAt,
      now: currentTime,
    );

    _profile = loaded.copyWith(
      animationState: restingState,
      lastActiveAt: currentTime,
    );
    _loading = false;
    _hasLoaded = true;
    notifyListeners();

    await _repository.saveLastActiveAt(currentTime);
  }

  /// The animation the mascot should idle in when there is no active event
  /// override, purely a function of when it was last opened.
  static PetAnimationState restingStateFor({
    required DateTime lastActiveAt,
    required DateTime now,
  }) {
    final daysSinceActive = now.difference(lastActiveAt).inDays;
    if (daysSinceActive >= kSleepAfterInactiveDays) {
      return PetAnimationState.sleep;
    }
    if (now.hour >= kNightStartHour && now.hour < kNightEndHour) {
      return PetAnimationState.sleep;
    }
    return PetAnimationState.idle;
  }

  /// Temporarily overrides the mascot's animation (e.g. `celebrate` when the
  /// user makes a new investment), then gracefully reverts to the resting
  /// state once [duration] elapses.
  void triggerEventAnimation(
    PetAnimationState state, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _revertTimer?.cancel();
    _profile = _profile.copyWith(animationState: state);
    notifyListeners();

    _revertTimer = Timer(duration, () {
      _profile = _profile.copyWith(
        animationState: restingStateFor(
          lastActiveAt: _profile.lastActiveAt,
          now: DateTime.now(),
        ),
      );
      notifyListeners();
    });
  }

  /// Returns the highest [PetEvolutionStage] whose rule is satisfied by
  /// [userXp] — evolution reflects learning/practice progression, never
  /// investment volume (`docs/PRODUCT_VISION.md` §9, §11). Rules are
  /// evaluated from strongest to weakest; [PetEvolutionRule.defaultRules]
  /// guarantees `babyDog` (0 XP) is always satisfied, so this never returns
  /// null.
  PetEvolutionStage resolveStage({
    required int userXp,
  }) {
    for (final rule in _rules) {
      if (rule.isSatisfiedBy(xp: userXp)) {
        return rule.stage;
      }
    }
    return PetEvolutionStage.babyDog;
  }

  /// Checks the evolution rules against the user's latest XP and, if a
  /// higher tier has been unlocked, upgrades the mascot and plays the
  /// `victory` animation. Also detects a level-up (see [LevelCalculator])
  /// from the same XP delta. Both are broadcast on [AppEventBus] so other
  /// systems (a toast today, a future Character Engine reaction) can react
  /// without this controller knowing who's listening.
  ///
  /// [currentNetWorth] is stored on the profile as a plain portfolio fact
  /// (shown informationally elsewhere) but never gates evolution — see
  /// [resolveStage].
  Future<void> evaluateEvolution(double currentNetWorth, int userXp) async {
    final resolvedStage = resolveStage(userXp: userXp);
    // Evolution never regresses: a temporary dip in net worth (e.g. a
    // withdrawal) must not strip a tier the user already earned.
    final didEvolve = resolvedStage.tier > _profile.stage.tier;
    final targetStage = didEvolve ? resolvedStage : _profile.stage;

    final previousLevel = LevelCalculator.fromXp(_profile.xp).level;
    final newLevel = LevelCalculator.fromXp(userXp).level;
    final xpDelta = userXp - _profile.xp;

    _profile = _profile.copyWith(
      stage: targetStage,
      netWorth: currentNetWorth,
      xp: userXp,
    );
    notifyListeners();

    await _repository.saveNetWorth(currentNetWorth);
    await _repository.saveXp(userXp);
    if (xpDelta > 0) {
      _eventBus.emit(XpGainedEvent(amount: xpDelta, newTotalXp: userXp));
    }
    if (didEvolve) {
      await _repository.saveStage(targetStage);
      triggerEventAnimation(PetAnimationState.victory, duration: const Duration(seconds: 4));
      _eventBus.emit(PetEvolvedEvent(targetStage));
    }
    if (newLevel > previousLevel) {
      _eventBus.emit(UserLeveledUpEvent(newLevel));
    }
  }

  Future<void> unlockAccessory(PetAccessoryId id) async {
    if (_profile.unlockedAccessories.contains(id)) return;
    final unlocked = {..._profile.unlockedAccessories, id};
    _profile = _profile.copyWith(unlockedAccessories: unlocked);
    notifyListeners();
    await _repository.saveUnlockedAccessories(unlocked);
  }

  /// Equips [accessory] in its slot, replacing whatever was equipped there.
  /// Throws a [StateError] if the accessory hasn't been unlocked yet.
  Future<void> equipAccessory(PetAccessory accessory) async {
    if (!_profile.unlockedAccessories.contains(accessory.id)) {
      throw StateError('Cannot equip a locked accessory: ${accessory.id}');
    }

    final equipped = {..._profile.equippedAccessories};
    equipped[accessory.type] = accessory.id;
    _profile = _profile.copyWith(equippedAccessories: equipped);
    notifyListeners();

    await _repository.saveEquippedAccessories(equipped);
  }

  Future<void> unequipAccessory(AccessoryType type) async {
    if (!_profile.equippedAccessories.containsKey(type)) return;

    final equipped = {..._profile.equippedAccessories}..remove(type);
    _profile = _profile.copyWith(equippedAccessories: equipped);
    notifyListeners();

    await _repository.saveEquippedAccessories(equipped);
  }

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }
}
