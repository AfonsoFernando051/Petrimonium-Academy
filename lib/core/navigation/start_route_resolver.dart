import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';

/// Where `MyApp` should route the user on cold start.
enum StartRoute { login, meetPet, financialGoal, tutorial, portfolioChoice, home }

/// Resolves [StartRoute] from persisted auth/onboarding state — extracted
/// from `MyApp._getStartRoute()` so the routing rules are testable without
/// `WidgetTester`. The rules are unchanged from the original inline
/// implementation, only moved here.
///
/// Each step gates the next one:
/// not authenticated -> [StartRoute.login]
/// authenticated, pet not configured (no species or no name yet) -> [StartRoute.meetPet]
/// pet configured, no financial goal chosen -> [StartRoute.financialGoal]
/// goal chosen, tutorial not finished -> [StartRoute.tutorial]
/// tutorial finished, portfolio step unresolved -> [StartRoute.portfolioChoice]
/// everything resolved -> [StartRoute.home]
///
/// Portfolio connection is intentionally optional: [StartRoute.portfolioChoice]
/// is shown at most once per account, and either connecting a portfolio *or*
/// explicitly skipping it resolves that step for good (see
/// `OnboardingStateRepository.isPortfolioStepDone`). Having zero holdings is
/// never, on its own, a reason to route back here — only an *unresolved*
/// step is.
class StartRouteResolver {
  StartRouteResolver({
    AuthRepository? authRepository,
    PetRepository? petRepository,
    MascotRepository? mascotRepository,
    OnboardingStateRepository? onboardingStateRepository,
  })  : _authRepository = authRepository ?? DI.authRepository,
        _petRepository = petRepository ?? DI.petRepository,
        _mascotRepository = mascotRepository ?? DI.mascotRepository,
        _onboardingStateRepository = onboardingStateRepository ?? DI.onboardingStateRepository;

  final AuthRepository _authRepository;
  final PetRepository _petRepository;
  final MascotRepository _mascotRepository;
  final OnboardingStateRepository _onboardingStateRepository;

  Future<StartRoute> resolve() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (!loggedIn) return StartRoute.login;

    try {
      final hasPet = await _petRepository.getPetStatus();
      final profile = await _mascotRepository.loadProfile();
      final hasName = profile.name != null && profile.name!.trim().isNotEmpty;
      if (!hasPet || !hasName) return StartRoute.meetPet;

      final hasSetGoal = await _onboardingStateRepository.hasSetGoal();
      if (!hasSetGoal) return StartRoute.financialGoal;

      final tutorialDone = await _onboardingStateRepository.isTutorialCompleted();
      if (!tutorialDone) return StartRoute.tutorial;

      final portfolioStepDone = await _onboardingStateRepository.isPortfolioStepDone();
      if (!portfolioStepDone) return StartRoute.portfolioChoice;

      return StartRoute.home;
    } catch (_) {
      // Any failure while resolving pet/onboarding state is treated as "not
      // safely resumable" — log the user out rather than risk stranding
      // them on a screen that assumes state that couldn't be loaded.
      await _authRepository.logout();
      return StartRoute.login;
    }
  }
}
