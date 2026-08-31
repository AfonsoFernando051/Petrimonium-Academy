import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('baseUrl defaults to localhost when API_BASE_URL is not provided', () {
      expect(ApiConstants.baseUrl, 'http://localhost:8081');
    });

    test('appContext identifies this binary as the Academy client', () {
      // Must never read 'wallet' — the backend gates
      // /api/v1/academy|learning|lab/** behind APP_CONTEXT_ACADEMY and
      // /api/investments/** behind APP_CONTEXT_WALLET, so this value alone
      // decides which side a login from this app ends up authorized for.
      expect(ApiConstants.appContext, 'academy');
    });

    test('endpoint constants are non-empty and well-formed', () {
      expect(ApiConstants.loginEndpoint, '/auth/login');
      expect(ApiConstants.registerEndpoint, '/auth/register');
      expect(ApiConstants.forgotPasswordEndpoint, '/auth/forgot-password');
      expect(ApiConstants.resetPasswordEndpoint, '/auth/reset-password');
      expect(ApiConstants.onboardingQuestionsEndpoint, '/api/onboarding/questions');
      expect(ApiConstants.onboardingSubmitEndpoint, '/api/onboarding/submit');
      expect(ApiConstants.onboardingStatusEndpoint, '/api/onboarding/status');
      expect(ApiConstants.settingsLanguageEndpoint, '/api/settings/language');
      expect(ApiConstants.mentorChatEndpoint, '/api/mentor/chat');
      expect(ApiConstants.mentorConversationsEndpoint, '/api/mentor/conversations');
      expect(ApiConstants.learningProgressEndpoint, '/api/v1/learning/progress');
      expect(ApiConstants.academyCatalogEndpoint, '/api/v1/academy/catalog');
      expect(ApiConstants.gamificationSummaryEndpoint, '/api/v1/gamification/summary');
      expect(ApiConstants.achievementsEndpoint, '/api/v1/achievements');
      expect(ApiConstants.missionsEndpoint, '/api/v1/missions');
      expect(ApiConstants.refreshTokenEndpoint, '/auth/refresh');
      expect(ApiConstants.logoutEndpoint, '/auth/logout');
    });

    test('mentorConversationEndpoint interpolates the given id', () {
      expect(ApiConstants.mentorConversationEndpoint(42), '/api/mentor/conversations/42');
    });

    test('learningLessonCompleteEndpoint interpolates the given lesson id', () {
      expect(
        ApiConstants.learningLessonCompleteEndpoint('lesson_abc'),
        '/api/v1/learning/lessons/lesson_abc/complete',
      );
    });

    test('assertConfiguredForRelease does not throw in debug/profile test builds', () {
      // kReleaseMode is false when running `flutter test`, so the release-only
      // localhost guard never fires here — this just documents that the call
      // is safe to make unconditionally at startup (see lib/main.dart).
      expect(ApiConstants.assertConfiguredForRelease, returnsNormally);
    });
  });
}
