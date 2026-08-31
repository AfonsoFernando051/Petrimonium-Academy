import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/theme/theme_controller.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/navigation/start_route_resolver.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/presentation/screens/login_screen.dart';
import 'package:petrimonium/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/journey_ready_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Build-time DSN for crash/error reporting, e.g.:
//   flutter build apk --dart-define=SENTRY_DSN=https://xxx@o0.ingest.sentry.io/0
// Left blank, SentryFlutter.init() below is a safe no-op (nothing is sent, nothing breaks) —
// same "empty disables it" pattern as the backend's optional API keys.
const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');

void main() async {
  ApiConstants.assertConfiguredForRelease();

  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.tracesSampleRate = kReleaseMode ? 0.2 : 0.0;
    },
    // SentryFlutter.init wraps this in its own error zone (on web, where
    // PlatformDispatcher.onError can't reliably catch Future errors), so both Flutter
    // framework errors and uncaught async errors reach Sentry automatically — no extra
    // runZonedGuarded needed here. Its own WidgetsFlutterBindingIntegration calls
    // WidgetsFlutterBinding.ensureInitialized() for us as the first step, inside that same
    // zone — calling it ourselves out here instead binds it to the wrong (outer) zone, which
    // Flutter detects as a "Zone mismatch" at runApp() and — on web — leaves the app on a
    // blank screen.
    appRunner: () async {
      await Translator.load();
      await ThemeController.load();
      await DI.onboardingStateRepository.incrementSessionCount();
      runApp(const MyApp());
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // A global key, not `Navigator.of(context)`, because `SessionExpiredEvent`
  // can arrive from `ApiClient` — deep in `core/`, with no `BuildContext` of
  // its own — at any point in the app's lifetime, not just from a widget
  // already in the tree. Same reasoning as any other "navigate from outside
  // the widget tree" need; every other in-tree navigation call in this app
  // still uses its own local `Navigator.of(context)` unchanged.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<AppEvent>? _sessionEventSubscription;

  @override
  void initState() {
    super.initState();
    _sessionEventSubscription = AppEventBus.instance.stream.listen(_onAppEvent);
  }

  void _onAppEvent(AppEvent event) {
    if (event is! SessionExpiredEvent) return;
    // Tokens are already cleared by the time this fires (see ApiClient) —
    // this only has to get the user looking at a screen that can log them
    // in again, clearing every route (Dashboard, an open lesson, whatever
    // was on screen) behind it.
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _sessionEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole app when the user switches language or theme in
    // Settings, since screens read Translator.translate()/context.colors
    // directly at build time.
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, _) => ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.themeModeNotifier,
        builder: (context, themeMode, _) => MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // Smooth, fast, non-flashy cross-fade on Light/Dark/System switch
          // (MaterialApp animates `theme`/`darkTheme` changes internally).
          themeAnimationDuration: const Duration(milliseconds: 280),
          themeAnimationCurve: Curves.easeOutCubic,
          home: FutureBuilder<StartRoute>(
            future: StartRouteResolver().resolve(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _SplashScreen();
              }

              switch (snapshot.data) {
                case StartRoute.home:
                  return const DashboardScreen();
                case StartRoute.portfolioChoice:
                  return const PortfolioChoiceScreen();
                case StartRoute.tutorial:
                  return const JourneyReadyScreen();
                case StartRoute.financialGoal:
                  return const FinancialGoalScreen();
                case StartRoute.meetPet:
                  return const WelcomeScreen();
                case StartRoute.login:
                case null:
                  return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Branded loading splash — replaces the plain white CircularProgressIndicator.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: tokens.backgroundPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.spaceDark,
                    AppColors.spacePurple,
                    AppColors.spaceBlue,
                  ]
                : [
                    tokens.backgroundPrimary,
                    tokens.primaryContainer,
                    tokens.backgroundSecondary,
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/generated_fox.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.pets, size: 80, color: tokens.primary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: tokens.primary,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Inicializando Módulo de Comandante...',
                style: GoogleFonts.outfit(
                  color: tokens.textSecondary,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
