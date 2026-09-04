import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/datasources/lab_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';
import 'package:petrimonium/features/game/data/repositories/gamification_repository.dart';
import 'package:petrimonium/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';
import 'package:petrimonium/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';
import 'package:petrimonium/features/pet/data/repositories/mascot_repository_impl.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_companion_preferences_repository.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_preferences_repository.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/mentor/data/datasources/mentor_remote_datasource.dart';
import 'package:petrimonium/features/mentor/data/repositories/mentor_chat_repository.dart';
import 'package:petrimonium/features/portfolio/data/datasources/achievements_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/datasources/missions_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/missions_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petrimonium/features/simulated_wallet/data/datasources/simulated_wallet_remote_datasource.dart';
import 'package:petrimonium/features/simulated_wallet/data/repositories/simulated_wallet_repository.dart';
import 'package:petrimonium/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:petrimonium/features/settings/data/repositories/settings_repository.dart';

class DI {
  static final ApiClient _apiClient = ApiClient();

  static final AuthRemoteDataSource _authRemoteDataSource =
      AuthRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static AuthRepository authRepository = AuthRepository(
    remoteDataSource: _authRemoteDataSource,
  );

  static final OnboardingRemoteDataSource _onboardingRemoteDataSource =
      OnboardingRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static OnboardingRepository onboardingRepository = OnboardingRepository(
    remoteDataSource: _onboardingRemoteDataSource,
  );

  // Not `final` so tests can replace it with a mock repository.
  static OnboardingStateRepository onboardingStateRepository =
      OnboardingStateRepository();

  static final PetRemoteDataSource _petRemoteDataSource = PetRemoteDataSource(
    apiClient: _apiClient,
  );
  // Not `final` so tests can replace it with a mock repository.
  static PetRepository petRepository = PetRepositoryImpl(
    remoteDataSource: _petRemoteDataSource,
  );

  static final GamificationRemoteDataSource _gamificationRemoteDataSource =
      GamificationRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static GamificationRepository gamificationRepository = GamificationRepository(
    remoteDataSource: _gamificationRemoteDataSource,
  );

  // Not `final` so tests can replace it with a mock repository.
  static MascotRepository mascotRepository = MascotRepositoryImpl(
    gamificationRemoteDataSource: _gamificationRemoteDataSource,
    petRemoteDataSource: _petRemoteDataSource,
  );

  // Not `final` so tests can replace it with a mock repository.
  static PetPreferencesRepository petPreferencesRepository =
      PetPreferencesRepository();

  // Not `final` so tests can replace it with a mock repository.
  static PetCompanionPreferencesRepository petCompanionPreferencesRepository =
      PetCompanionPreferencesRepository();

  static final SettingsRemoteDataSource _settingsRemoteDataSource =
      SettingsRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static SettingsRepository settingsRepository = SettingsRepository(
    remoteDataSource: _settingsRemoteDataSource,
  );

  static final PortfolioRemoteDataSource _portfolioRemoteDataSource =
      PortfolioRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static PortfolioRepository portfolioRepository = PortfolioRepository(
    remoteDataSource: _portfolioRemoteDataSource,
  );

  static final SimulatedWalletRemoteDataSource _simulatedWalletRemoteDataSource =
      SimulatedWalletRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static SimulatedWalletRepository simulatedWalletRepository = SimulatedWalletRepository(
    remoteDataSource: _simulatedWalletRemoteDataSource,
  );

  // Not `final` so tests can replace it with a mock repository.
  static AchievementsLocalRepository achievementsLocalRepository =
      AchievementsLocalRepository();

  static final AchievementsRemoteDataSource _achievementsRemoteDataSource =
      AchievementsRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static AchievementsRepository achievementsRepository = AchievementsRepository(
    remoteDataSource: _achievementsRemoteDataSource,
  );

  static final MissionsRemoteDataSource _missionsRemoteDataSource =
      MissionsRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static MissionsRepository missionsRepository = MissionsRepository(
    remoteDataSource: _missionsRemoteDataSource,
  );

  // Not `final` so tests can replace it with a mock repository.
  static AcademyProgressLocalRepository academyProgressRepository =
      AcademyProgressLocalRepository();

  // Not `final` so tests can replace it with a mock datasource.
  static AcademyRemoteDataSource academyRemoteDataSource =
      AcademyRemoteDataSource(apiClient: _apiClient);

  // Not `final` so tests can replace it with a mock datasource.
  static LabRemoteDataSource labRemoteDataSource =
      LabRemoteDataSource(apiClient: _apiClient);

  // Not `final` so tests can replace it with a mock repository.
  static AcademyCatalogRepository academyCatalogRepository =
      AcademyCatalogRepository(apiClient: _apiClient);

  static final MentorRemoteDataSource _mentorRemoteDataSource =
      MentorRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static MentorChatRepository mentorChatRepository = MentorChatRepository(
    remoteDataSource: _mentorRemoteDataSource,
    petPreferencesRepository: petPreferencesRepository,
  );
}
