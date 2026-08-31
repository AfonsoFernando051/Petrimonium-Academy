import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';

void main() {
  late OnboardingStateRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = OnboardingStateRepository();
  });

  group('hasSetGoal / setGoalChosen', () {
    test('defaults to false', () async {
      expect(await repository.hasSetGoal(), isFalse);
    });

    test('becomes true after setGoalChosen', () async {
      await repository.setGoalChosen();
      expect(await repository.hasSetGoal(), isTrue);
    });
  });

  group('isTutorialCompleted / completeTutorial', () {
    test('defaults to false', () async {
      expect(await repository.isTutorialCompleted(), isFalse);
    });

    test('becomes true after completeTutorial', () async {
      await repository.completeTutorial();
      expect(await repository.isTutorialCompleted(), isTrue);
    });
  });

  group('isPortfolioStepDone / isPortfolioConnected', () {
    test(
      'both default to false — the step is unresolved until the user acts',
      () async {
        expect(await repository.isPortfolioStepDone(), isFalse);
        expect(await repository.isPortfolioConnected(), isFalse);
      },
    );

    test(
      'markPortfolioConnected resolves the step as connected and clears any prior skip',
      () async {
        await repository.markPortfolioSkipped(now: DateTime(2024, 1, 1));
        await repository.markPortfolioConnected();

        expect(await repository.isPortfolioStepDone(), isTrue);
        expect(await repository.isPortfolioConnected(), isTrue);
        // A stale skip timestamp must not survive a later connect — otherwise
        // shouldShowPortfolioReminder could still fire for a user who already
        // connected their portfolio.
        expect(await repository.shouldShowPortfolioReminder(), isFalse);
      },
    );

    test(
      'markPortfolioSkipped resolves the step as done but not connected',
      () async {
        await repository.markPortfolioSkipped(now: DateTime(2024, 1, 1));

        expect(await repository.isPortfolioStepDone(), isTrue);
        expect(await repository.isPortfolioConnected(), isFalse);
      },
    );
  });

  group('incrementSessionCount / currentSessionCount', () {
    test('starts at 0 and increments by 1 each call', () async {
      expect(await repository.currentSessionCount(), 0);

      expect(await repository.incrementSessionCount(), 1);
      expect(await repository.currentSessionCount(), 1);

      expect(await repository.incrementSessionCount(), 2);
      expect(await repository.currentSessionCount(), 2);
    });
  });

  group('shouldShowPortfolioReminder', () {
    test(
      'never true if the user never reached/skipped the portfolio step',
      () async {
        for (var i = 0; i < kPortfolioReminderAfterSessions + 5; i++) {
          await repository.incrementSessionCount();
        }
        expect(await repository.shouldShowPortfolioReminder(), isFalse);
      },
    );

    test(
      'never true if the user connected a portfolio (not skipped)',
      () async {
        await repository.markPortfolioConnected();
        for (var i = 0; i < kPortfolioReminderAfterSessions + 5; i++) {
          await repository.incrementSessionCount();
        }
        expect(await repository.shouldShowPortfolioReminder(), isFalse);
      },
    );

    test(
      'false before kPortfolioReminderAfterSessions sessions have passed since skipping',
      () async {
        await repository.markPortfolioSkipped();
        for (var i = 0; i < kPortfolioReminderAfterSessions - 1; i++) {
          await repository.incrementSessionCount();
        }
        expect(await repository.shouldShowPortfolioReminder(), isFalse);
      },
    );

    test(
      'true once kPortfolioReminderAfterSessions sessions have passed since skipping',
      () async {
        await repository.markPortfolioSkipped();
        for (var i = 0; i < kPortfolioReminderAfterSessions; i++) {
          await repository.incrementSessionCount();
        }
        expect(await repository.shouldShowPortfolioReminder(), isTrue);
      },
    );

    test(
      'false again immediately after being shown (before the cooldown elapses)',
      () async {
        await repository.markPortfolioSkipped();
        int session = 0;
        for (var i = 0; i < kPortfolioReminderAfterSessions; i++) {
          session = await repository.incrementSessionCount();
        }
        expect(await repository.shouldShowPortfolioReminder(), isTrue);
        await repository.markReminderShown(session);

        expect(await repository.shouldShowPortfolioReminder(), isFalse);
      },
    );

    test(
      'true again once kPortfolioReminderCooldownSessions have passed since the last reminder',
      () async {
        await repository.markPortfolioSkipped();
        int session = 0;
        for (var i = 0; i < kPortfolioReminderAfterSessions; i++) {
          session = await repository.incrementSessionCount();
        }
        await repository.markReminderShown(session);
        expect(await repository.shouldShowPortfolioReminder(), isFalse);

        for (var i = 0; i < kPortfolioReminderCooldownSessions - 1; i++) {
          await repository.incrementSessionCount();
        }
        expect(await repository.shouldShowPortfolioReminder(), isFalse);

        await repository.incrementSessionCount();
        expect(await repository.shouldShowPortfolioReminder(), isTrue);
      },
    );
  });

  group('hasSeenPortfolioActivation / markPortfolioActivationSeen', () {
    test('defaults to false', () async {
      expect(await repository.hasSeenPortfolioActivation(), isFalse);
    });

    test('becomes true after markPortfolioActivationSeen', () async {
      await repository.markPortfolioActivationSeen();
      expect(await repository.hasSeenPortfolioActivation(), isTrue);
    });

    test('is independent of the portfolio-connected/skipped flags', () async {
      await repository.markPortfolioSkipped(now: DateTime(2024, 1, 1));
      expect(await repository.hasSeenPortfolioActivation(), isFalse);

      await repository.markPortfolioActivationSeen();
      await repository.markPortfolioConnected();
      expect(await repository.hasSeenPortfolioActivation(), isTrue);
    });
  });
}
