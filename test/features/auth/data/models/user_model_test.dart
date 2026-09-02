import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson should return a valid model when both email and token are provided', () {
      final Map<String, dynamic> jsonMap = {
        'email': 'test@test.com',
        'accessToken': 'mock_token',
      };
      
      final result = UserModel.fromJson(jsonMap);
      
      expect(result.email, 'test@test.com');
      expect(result.token, 'mock_token');
    });

    test('fromJson should handle missing token safely', () {
      final Map<String, dynamic> jsonMap = {
        'email': 'test@test.com',
      };
      
      final result = UserModel.fromJson(jsonMap);
      
      expect(result.email, 'test@test.com');
      expect(result.token, isNull);
    });

    test('fromJson should handle null email safely fallback to empty string', () {
      final Map<String, dynamic> jsonMap = {
        'accessToken': 'mock_token',
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.email, '');
    });

    test('fromJson parses refreshToken when present', () {
      final Map<String, dynamic> jsonMap = {
        'email': 'test@test.com',
        'accessToken': 'mock_token',
        'refreshToken': 'mock_refresh_token',
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.refreshToken, 'mock_refresh_token');
    });

    test('fromJson handles missing refreshToken safely', () {
      final Map<String, dynamic> jsonMap = {
        'email': 'test@test.com',
        'accessToken': 'mock_token',
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.refreshToken, isNull);
    });

    test('fromJson parses username when present (register/users-me responses)', () {
      final Map<String, dynamic> jsonMap = {
        'email': 'test@test.com',
        'username': 'investor',
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.username, 'investor');
    });

    test('fromJson handles missing username safely (login response)', () {
      final Map<String, dynamic> jsonMap = {
        'accessToken': 'mock_token',
        'refreshToken': 'mock_refresh_token',
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.username, isNull);
    });
  });
}
