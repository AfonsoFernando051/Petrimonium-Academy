import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';

/// The shared contract between the Pet's communication layer
/// (`PetCompanionController`) and each app's own reaction script. Shaped so
/// it can become the public surface of a vendored `pet_engine` package once
/// Academy and Wallet are split across repos (see the cross-repo contract
/// proposal doc) — for now it stays local Dart code, duplicated-but-
/// contract-matched between the two apps rather than an actual shared
/// package.
///
/// An implementation only answers for the [PetContext]s/[AppEvent]s it owns
/// and returns `null` for everything else — `PetCompanionController` tries
/// each registered [PetBehavior] in order and takes the first non-null
/// result, so multiple behaviors can coexist without knowing about each
/// other (see its own doc comment for why that matters: Academy's script
/// must stay swappable without Wallet's implementation, and vice versa).
abstract class PetBehavior {
  const PetBehavior();

  /// A nudge offered when the user lands on [context], or `null` if this
  /// behavior has nothing to say for it.
  PetMessage? pageEnter(
    PetContext context, {
    required int userXp,
    Map<String, String> data,
  });

  /// A reaction to something that just happened, or `null` if this behavior
  /// doesn't react to [event].
  PetMessage? onEvent(AppEvent event);

  /// Genuinely content-free encouragement this behavior can offer when a
  /// context has nothing more specific to say — most behaviors have none.
  PetMessage? ambientFallback() => null;
}
