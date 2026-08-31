import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/data/models/user_model.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockApiClient mockApiClient;
  late AuthRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    when(() => mockRemoteDataSource.apiClient).thenReturn(mockApiClient);
    when(() => mockApiClient.saveTokens(accessToken: any(named: 'accessToken'), refreshToken: any(named: 'refreshToken')))
        .thenAnswer((_) async {});
    when(() => mockApiClient.readToken()).thenAnswer((_) async => null);
    when(() => mockApiClient.readRefreshToken()).thenAnswer((_) async => null);
    when(() => mockApiClient.clearTokens()).thenAnswer((_) async {});
    when(() => mockRemoteDataSource.logout(any())).thenAnswer((_) async {});
    repository = AuthRepository(remoteDataSource: mockRemoteDataSource);
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthRepository', () {
    final tName = 'Test User';
    final tEmail = 'test@example.com';
    final tPassword = 'password123';
    final tToken = 'mock_token';
    final tRefreshToken = 'mock_refresh_token';
    final tUserModel = UserModel(email: tEmail, token: tToken, refreshToken: tRefreshToken);

    test('should call login on remote data source and save both tokens via ApiClient (secure storage)', () async {
      // arrange
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => tUserModel);

      // act
      await repository.login(tEmail, tPassword);

      // assert
      verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
      verify(() => mockApiClient.saveTokens(accessToken: tToken, refreshToken: tRefreshToken)).called(1);
    });

    test('should call remoteDataSource.register and save both tokens via ApiClient when register is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.register(any(), any(), any()))
          .thenAnswer((_) async => UserModel(email: tEmail, token: tToken, refreshToken: tRefreshToken));

      // act
      await repository.register(tName, tEmail, tPassword);

      // assert
      verify(() => mockRemoteDataSource.register(tName, tEmail, tPassword)).called(1);
      verify(() => mockApiClient.saveTokens(accessToken: tToken, refreshToken: tRefreshToken)).called(1);
    });

    test('should not save tokens when the backend response carries no refresh token (e.g. register today)', () async {
      // Register's backend response has no token pair yet — _saveTokens must
      // no-op rather than call ApiClient with a null refreshToken.
      when(() => mockRemoteDataSource.register(any(), any(), any()))
          .thenAnswer((_) async => UserModel(email: tEmail, token: null, refreshToken: null));

      await repository.register(tName, tEmail, tPassword);

      verifyNever(() => mockApiClient.saveTokens(accessToken: any(named: 'accessToken'), refreshToken: any(named: 'refreshToken')));
    });

    test('should call requestPasswordReset on remote data source', () async {
      when(() => mockRemoteDataSource.requestPasswordReset(any())).thenAnswer((_) async {});

      await repository.requestPasswordReset(tEmail);

      verify(() => mockRemoteDataSource.requestPasswordReset(tEmail)).called(1);
    });

    test('should call resetPassword on remote data source', () async {
      when(() => mockRemoteDataSource.resetPassword(any(), any())).thenAnswer((_) async {});

      await repository.resetPassword('reset-token', tPassword);

      verify(() => mockRemoteDataSource.resetPassword('reset-token', tPassword)).called(1);
    });

    test('should return true if isLoggedIn when a token exists in secure storage', () async {
      // arrange
      when(() => mockApiClient.readToken()).thenAnswer((_) async => tToken);

      // act
      final result = await repository.isLoggedIn();

      // assert
      expect(result, isTrue);
    });

    test('should return false if isLoggedIn when token is null', () async {
      // act
      final result = await repository.isLoggedIn();

      // assert
      expect(result, isFalse);
    });

    test('should revoke the refresh token server-side and clear both tokens and the saved email on logout', () async {
      // arrange
      SharedPreferences.setMockInitialValues({'auth_email': tEmail});
      when(() => mockApiClient.readRefreshToken()).thenAnswer((_) async => tRefreshToken);

      // act
      await repository.logout();

      // assert
      verify(() => mockRemoteDataSource.logout(tRefreshToken)).called(1);
      verify(() => mockApiClient.clearTokens()).called(1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_email'), isNull);
    });

    test('logout still clears local state even when revoking the refresh token server-side fails', () async {
      SharedPreferences.setMockInitialValues({'auth_email': tEmail});
      when(() => mockApiClient.readRefreshToken()).thenAnswer((_) async => tRefreshToken);
      when(() => mockRemoteDataSource.logout(any())).thenThrow(Exception('offline'));

      await repository.logout();

      verify(() => mockApiClient.clearTokens()).called(1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_email'), isNull);
    });

    test('logout skips the server call when there is no stored refresh token', () async {
      SharedPreferences.setMockInitialValues({'auth_email': tEmail});
      when(() => mockApiClient.readRefreshToken()).thenAnswer((_) async => null);

      await repository.logout();

      verifyNever(() => mockRemoteDataSource.logout(any()));
      verify(() => mockApiClient.clearTokens()).called(1);
    });
  });
}
