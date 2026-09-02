import 'package:flutter/foundation.dart';

class ApiConstants {
  // Overridable per build without editing source, e.g.:
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081   (Android emulator)
  //   flutter build apk --dart-define=API_BASE_URL=https://api.example.com  (prod)
  // Defaults to http://localhost:8081, which works for iOS Simulator/Web but
  // NOT the Android emulator (use 10.0.2.2 there) — see README.md.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );

  static const String _devDefaultBaseUrl = 'http://localhost:8081';

  // The Web OAuth 2.0 Client ID from Google Cloud Console, passed to
  // GoogleSignIn as serverClientId so the ID token it returns is valid for
  // this backend's `google.oauth.client-ids` audience check. Empty by
  // default — Google Sign-In is not usable until this is supplied, e.g.:
  //   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  /// A release build that never received --dart-define=API_BASE_URL=... would otherwise
  /// silently ship pointed at a developer's own machine — fail loudly and immediately
  /// instead, rather than have every request quietly fail (or worse, quietly succeed against
  /// the wrong backend) in front of a real user.
  static void assertConfiguredForRelease() {
    if (kReleaseMode && baseUrl == _devDefaultBaseUrl) {
      throw StateError(
        'API_BASE_URL was not set for this release build — it would point at '
        'localhost. Build with --dart-define=API_BASE_URL=<real backend URL>.',
      );
    }
  }

  // Identifies this app to the backend at login so the issued JWT carries the
  // matching `app_context` claim — required as of backend commit 7b51782,
  // which gates /api/v1/academy|learning|lab/** behind APP_CONTEXT_ACADEMY.
  // Fixed per-app value, not a build flag: this binary is only ever the
  // Academy client.
  static const String appContext = 'academy';

  static const String loginEndpoint = '/auth/login';
  static const String googleLoginEndpoint = '/auth/google';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String currentUserEndpoint = '/api/users/me';

  static const String onboardingQuestionsEndpoint = '/api/onboarding/questions';
  static const String onboardingSubmitEndpoint = '/api/onboarding/submit';
  static const String onboardingStatusEndpoint = '/api/onboarding/status';

  static const String settingsLanguageEndpoint = '/api/settings/language';

  static const String mentorChatEndpoint = '/api/mentor/chat';
  static String mentorSuggestionsEndpoint(String language) =>
      '/api/mentor/suggestions?language=$language';
  static const String mentorConversationsEndpoint = '/api/mentor/conversations';
  static String mentorConversationEndpoint(int id) =>
      '/api/mentor/conversations/$id';

  static String learningLessonCompleteEndpoint(String lessonId) =>
      '/api/v1/learning/lessons/$lessonId/complete';
  static const String learningProgressEndpoint = '/api/v1/learning/progress';

  static String labSimulatorCompleteEndpoint(String simulatorId) =>
      '/api/v1/lab/simulators/$simulatorId/complete';
  static const String labSimulatorsProgressEndpoint =
      '/api/v1/lab/simulators/progress';
  static const String academyCatalogEndpoint = '/api/v1/academy/catalog';

  static const String gamificationSummaryEndpoint =
      '/api/v1/gamification/summary';
  static const String achievementsEndpoint = '/api/v1/achievements';
  static const String missionsEndpoint = '/api/v1/missions';

  // Academy's simulated wallet — entirely separate backend context
  // (simulated_portfolio), never real_portfolio's /api/investments/*. See
  // Petrimonium-Backend docs/BACKEND_MODULE_PLAN.md §11.
  static const String simulatedPortfolioMeEndpoint =
      '/api/v1/simulated-portfolios/me';
  static const String simulatedPortfolioOrdersEndpoint =
      '/api/v1/simulated-portfolios/orders';
  static const String simulatedPortfolioResetEndpoint =
      '/api/v1/simulated-portfolios/reset';
  static String simulatedPortfolioQuoteSearchEndpoint(String query) =>
      '/api/v1/simulated-portfolios/quotes/search?query=$query';
  static String simulatedPortfolioQuoteEndpoint(String ticker) =>
      '/api/v1/simulated-portfolios/quotes/$ticker';
}
