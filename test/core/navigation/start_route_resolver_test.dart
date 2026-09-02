import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/navigation/start_route_resolver.dart';
import 'package:petrimonium/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';

/// In-memory [AuthRepository] double — real `AuthRepository` reads/writes
/// `SharedPreferences` directly, which isn't available in a plain unit test.
class FakeAuthRepository implements AuthRepository {
  bool loggedIn = true;
  bool logoutCalled = false;

  @override
  Future<bool> isLoggedIn() async => loggedIn;

  @override
  Future<void> logout() async {
    logoutCalled = true;
    loggedIn = false;
  }

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> loginWithGoogle() async {}

  @override
  Future<void> register(String name, String email, String password) async {}

  @override
  Future<String?> getSavedEmail() async => null;

  @override
  Future<String?> getSavedUserName() async => null;

  @override
  Future<String?> refreshUserName() async => null;

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> resetPassword(String token, String newPassword) async {}

  @override
  AuthRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

class FakePetRepository implements PetRepository {
  bool hasPet = true;
  Object? statusError;

  @override
  Future<bool> getPetStatus() async {
    if (statusError != null) throw statusError!;
    return hasPet;
  }

  @override
  Future<void> configurePet(PetSpecieEnum specie) async {}

  @override
  Future<Map<String, dynamic>?> getMyPet() async => null;
}

class FakeMascotRepository implements MascotRepository {
  PetProfile profileToReturn = PetProfile(name: 'Rex');

  @override
  Future<PetProfile> loadProfile() async => profileToReturn;

  @override
  Future<void> saveName(String name) async {}

  @override
  Future<void> saveStage(PetEvolutionStage stage) async {}

  @override
  Future<void> saveXp(int xp) async {}

  @override
  Future<void> saveSpecie(PetSpecieEnum specie) async {}

  @override
  Future<void> saveNetWorth(double netWorth) async {}

  @override
  Future<void> saveEquippedAccessories(
    Map<AccessoryType, PetAccessoryId> equipped,
  ) async {}

  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}

  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

/// In-memory [OnboardingStateRepository] double for the fields
/// [StartRouteResolver] actually reads.
class FakeOnboardingStateRepository implements OnboardingStateRepository {
  bool hasSetGoalValue = true;
  bool tutorialCompleted = true;
  bool portfolioStepDone = true;

  @override
  Future<bool> hasSetGoal() async => hasSetGoalValue;

  @override
  Future<bool> isTutorialCompleted() async => tutorialCompleted;

  @override
  Future<bool> isPortfolioStepDone() async => portfolioStepDone;

  @override
  Future<void> setGoalChosen() async {}

  @override
  Future<void> completeTutorial() async {}

  @override
  Future<bool> isPortfolioConnected() async => false;

  @override
  Future<void> markPortfolioConnected() async {}

  @override
  Future<void> markPortfolioSkipped({DateTime? now}) async {}

  @override
  Future<int> incrementSessionCount() async => 0;

  @override
  Future<int> currentSessionCount() async => 0;

  @override
  Future<void> markReminderShown(int atSession) async {}

  @override
  Future<bool> shouldShowPortfolioReminder() async => false;

  @override
  Future<bool> hasSeenPortfolioActivation() async => false;

  @override
  Future<void> markPortfolioActivationSeen() async {}
}

void main() {
  late FakeAuthRepository authRepository;
  late FakePetRepository petRepository;
  late FakeMascotRepository mascotRepository;
  late FakeOnboardingStateRepository onboardingStateRepository;
  late StartRouteResolver resolver;

  setUp(() {
    authRepository = FakeAuthRepository();
    petRepository = FakePetRepository();
    mascotRepository = FakeMascotRepository();
    onboardingStateRepository = FakeOnboardingStateRepository();
    resolver = StartRouteResolver(
      authRepository: authRepository,
      petRepository: petRepository,
      mascotRepository: mascotRepository,
      onboardingStateRepository: onboardingStateRepository,
    );
  });

  test(
    'not logged in routes to login, before touching any other state',
    () async {
      authRepository.loggedIn = false;

      final route = await resolver.resolve();

      expect(route, StartRoute.login);
    },
  );

  test('logged in but no pet configured routes to meetPet', () async {
    petRepository.hasPet = false;

    final route = await resolver.resolve();

    expect(route, StartRoute.meetPet);
  });

  test('pet configured but unnamed routes to meetPet', () async {
    mascotRepository.profileToReturn = PetProfile(name: null);

    final route = await resolver.resolve();

    expect(route, StartRoute.meetPet);
  });

  test('pet configured but name is blank routes to meetPet', () async {
    mascotRepository.profileToReturn = PetProfile(name: '   ');

    final route = await resolver.resolve();

    expect(route, StartRoute.meetPet);
  });

  test(
    'pet ready but no financial goal chosen routes to financialGoal',
    () async {
      onboardingStateRepository.hasSetGoalValue = false;

      final route = await resolver.resolve();

      expect(route, StartRoute.financialGoal);
    },
  );

  test('goal chosen but tutorial unfinished routes to tutorial', () async {
    onboardingStateRepository.tutorialCompleted = false;

    final route = await resolver.resolve();

    expect(route, StartRoute.tutorial);
  });

  test(
    'tutorial done but portfolio step unresolved routes to portfolioChoice',
    () async {
      onboardingStateRepository.portfolioStepDone = false;

      final route = await resolver.resolve();

      expect(route, StartRoute.portfolioChoice);
    },
  );

  test('everything resolved routes home', () async {
    final route = await resolver.resolve();

    expect(route, StartRoute.home);
  });

  test(
    'portfolio step resolved via skip (not just connect) still routes home — portfolio stays optional',
    () async {
      // isPortfolioStepDone() is true whether the user connected or skipped;
      // the resolver must not distinguish between the two, or treat an empty
      // portfolio as a reason to route back to portfolioChoice.
      onboardingStateRepository.portfolioStepDone = true;

      final route = await resolver.resolve();

      expect(route, StartRoute.home);
    },
  );

  test(
    'a failure reading pet/onboarding state logs the user out and routes to login',
    () async {
      petRepository.statusError = Exception('boom');

      final route = await resolver.resolve();

      expect(route, StartRoute.login);
      expect(authRepository.logoutCalled, isTrue);
    },
  );

  test(
    'a failure never routes to a screen that assumes unavailable state',
    () async {
      petRepository.statusError = Exception('network down');

      final route = await resolver.resolve();

      expect(route, isNot(StartRoute.home));
      expect(route, isNot(StartRoute.meetPet));
    },
  );
}
