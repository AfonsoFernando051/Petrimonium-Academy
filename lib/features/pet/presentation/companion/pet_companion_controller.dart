import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/features/academy/domain/services/academy_pet_behavior.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_companion_preferences_repository.dart';
import 'package:petrimonium/features/pet/domain/behavior/core_pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/behavior/pet_behavior.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/domain/services/portfolio_pet_behavior.dart';

/// The Pet's reaction scripts, tried in order for every [pageEnter]/event —
/// first non-null result wins. `CorePetBehavior` owns identity/gamification
/// state (XP/level/evolution) that's shared regardless of app;
/// `AcademyPetBehavior` and `PortfolioPetBehavior` are this app's two
/// isolated, independently swappable scripts (see their own doc comments).
const List<PetBehavior> _kPetBehaviors = [
  CorePetBehavior(),
  AcademyPetBehavior(),
  PortfolioPetBehavior(),
];

/// How long a [PetMessageTrigger.pageEnter] nudge stays cooled down after
/// being shown, so returning to the same tab a minute later doesn't repeat
/// it — see `docs` product spec §24/§25 ("avoid annoying the user").
const Duration kPetMessageCooldown = Duration(hours: 6);

/// Single source of truth for the persistent pet companion's speech-bubble
/// state: which [PetMessage] (if any) is currently showing, and the
/// interaction sheet's open/closed state. Wraps [MascotController] rather
/// than duplicating pet identity/animation state — this controller only
/// owns *communication*, not the pet's gamification state.
///
/// One instance lives for the app's authenticated session (owned by
/// `DashboardScreen`, alongside `MascotController`/`PortfolioController`)
/// and is threaded into every screen that hosts a `PetCompanionHeader`, so
/// there is exactly one message queue/cooldown ledger — never one per
/// screen.
class PetCompanionController extends ChangeNotifier {
  PetCompanionController({
    required MascotController mascotController,
    PetCompanionPreferencesRepository? preferencesRepository,
    AppEventBus? eventBus,
  }) : _mascotController = mascotController,
       _preferences =
           preferencesRepository ?? PetCompanionPreferencesRepository(),
       _eventBus = eventBus ?? AppEventBus.instance {
    _eventSubscription = _eventBus.stream.listen(_onAppEvent);
    _loadHistory();
  }

  final MascotController _mascotController;
  final PetCompanionPreferencesRepository _preferences;
  final AppEventBus _eventBus;
  late final StreamSubscription<AppEvent> _eventSubscription;

  Map<String, DateTime> _lastShown = {};
  PetMessage? _currentMessage;
  DateTime? _currentMessageShownAt;
  Timer? _autoHideTimer;
  bool _isInteractionOpen = false;

  PetMessage? get currentMessage => _currentMessage;
  bool get isSpeaking => _currentMessage != null;
  bool get isInteractionOpen => _isInteractionOpen;
  MascotController get mascotController => _mascotController;

  Future<void> _loadHistory() async {
    _lastShown = await _preferences.loadLastShown();
  }

  /// Called when a screen for [context] is entered/becomes visible. Offers
  /// that context's page-enter nudge (see `PetMessageCatalog.pageEnter`),
  /// which only actually appears if nothing higher-priority is already
  /// showing and it isn't still cooling down from a recent showing.
  ///
  /// [allowAmbientFallback] (Home only — see `_HomeScreenState
  /// .notifyCompanionOnce`, its only caller) substitutes
  /// `PetMessageCatalog.homeMotivationalFallback` whenever the real nudge
  /// is either absent *or* still cooling down from a recent showing — this
  /// controller is where that decision has to live, since it alone holds
  /// [_lastShown]; the catalog itself has no notion of cooldown. Left
  /// `false` by `DashboardScreen._initCompanionGreeting`'s early, low-info
  /// call so it can't "claim" the message slot with filler before
  /// `HomeScreen`'s later, data-informed call gets a chance to offer
  /// something real.
  void enterContext(
    PetContext context, {
    Map<String, String> data = const {},
    bool allowAmbientFallback = false,
  }) {
    var message = _firstNonNull(
      (behavior) => behavior.pageEnter(
        context,
        userXp: _mascotController.profile.xp,
        data: data,
      ),
    );
    if (allowAmbientFallback &&
        (message == null || _isCoolingDown(message.id))) {
      message = _firstNonNull((behavior) => behavior.ambientFallback());
    }
    if (message == null) return;
    _offer(message, bypassCooldown: false);
  }

  PetMessage? _firstNonNull(PetMessage? Function(PetBehavior) resolve) {
    for (final behavior in _kPetBehaviors) {
      final message = resolve(behavior);
      if (message != null) return message;
    }
    return null;
  }

  bool _isCoolingDown(String messageId) {
    final lastShown = _lastShown[messageId];
    return lastShown != null &&
        DateTime.now().difference(lastShown) < kPetMessageCooldown;
  }

  void _onAppEvent(AppEvent event) {
    // A session expiring is a plumbing concern (see ApiClient/main.dart's
    // root listener, which handles the actual logout-and-redirect) — not a
    // moment the companion should comment on.
    if (event is SessionExpiredEvent) return;
    final message = _firstNonNull((behavior) => behavior.onEvent(event));
    if (message == null) return;
    _offer(message, bypassCooldown: true);
  }

  void _offer(PetMessage message, {required bool bypassCooldown}) {
    if (!bypassCooldown) {
      if (_isCoolingDown(message.id)) return;
      // A page-enter nudge never interrupts whatever is already showing
      // (an event reaction or another nudge) — it simply waits its turn.
      if (_currentMessage != null) return;
    } else if (_currentMessage != null) {
      // Event reactions may replace a lower/equal-priority message, but a
      // high-priority moment (level-up, evolution) gets a short grace
      // window so a same-tick XP-gain reaction can't immediately clobber it.
      final currentPriority = _currentMessage!.priority.index;
      final incomingPriority = message.priority.index;
      final elapsedSinceShown = _currentMessageShownAt == null
          ? Duration.zero
          : DateTime.now().difference(_currentMessageShownAt!);
      final graceWindowActive =
          _currentMessage!.priority == PetMessagePriority.high &&
          elapsedSinceShown < const Duration(seconds: 3);
      if (incomingPriority < currentPriority || graceWindowActive) return;
    }

    _show(message);
  }

  void _show(PetMessage message) {
    _autoHideTimer?.cancel();
    _currentMessage = message;
    _currentMessageShownAt = DateTime.now();
    notifyListeners();

    _lastShown[message.id] = _currentMessageShownAt!;
    unawaited(_preferences.recordShown(message.id, _currentMessageShownAt!));

    final displayDuration = _autoHideDurationFor(message.priority);
    // The mascot visually reacts for as long as the bubble is up — see
    // `PetMessage.mood`'s doc comment, which described this pairing before
    // anything actually wired it.
    _mascotController.triggerEventAnimation(message.mood, duration: displayDuration);

    _autoHideTimer = Timer(displayDuration, () {
      if (_currentMessage?.id == message.id) dismiss();
    });
  }

  Duration _autoHideDurationFor(PetMessagePriority priority) =>
      switch (priority) {
        PetMessagePriority.low => const Duration(seconds: 5),
        PetMessagePriority.normal => const Duration(seconds: 7),
        PetMessagePriority.high => const Duration(seconds: 9),
      };

  /// Hides the current speech bubble. Does not permanently suppress the
  /// message — it can be offered again once `kPetMessageCooldown` elapses,
  /// a new event fires, or the user reopens the interaction sheet.
  void dismiss() {
    if (_currentMessage == null) return;
    _autoHideTimer?.cancel();
    _currentMessage = null;
    _currentMessageShownAt = null;
    notifyListeners();
  }

  void openInteraction() {
    if (_isInteractionOpen) return;
    _isInteractionOpen = true;
    notifyListeners();
  }

  void closeInteraction() {
    if (!_isInteractionOpen) return;
    _isInteractionOpen = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _eventSubscription.cancel();
    super.dispose();
  }
}
