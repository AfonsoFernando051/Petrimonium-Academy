import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:petrimonium/core/network/api_error_parser.dart';

http.Response _jsonResponse(Map<String, dynamic> body, int statusCode) {
  return http.Response(jsonEncode(body), statusCode);
}

void main() {
  group('extractErrorDetail', () {
    test('extracts the detail field from a ProblemDetail-shaped body', () {
      final response = _jsonResponse({
        'type': 'about:blank',
        'title': 'Bad Request',
        'status': 400,
        'detail': 'password: must be at least 8 characters long',
        'code': 'VALIDATION_ERROR',
      }, 400);

      final result = extractErrorDetail(response, fallback: 'fallback');

      expect(result, 'password: must be at least 8 characters long');
    });

    test('falls back when the body is empty', () {
      final response = http.Response('', 400);

      final result = extractErrorDetail(response, fallback: 'Failed to register.');

      expect(result, 'Failed to register.');
    });

    test('falls back when the body is not JSON (e.g. a proxy error page)', () {
      final response = http.Response('<html><body>502 Bad Gateway</body></html>', 502);

      final result = extractErrorDetail(response, fallback: 'Failed to register.');

      expect(result, 'Failed to register.');
    });

    test('falls back when the JSON body has no detail field', () {
      final response = _jsonResponse({'status': 500}, 500);

      final result = extractErrorDetail(response, fallback: 'Something went wrong.');

      expect(result, 'Something went wrong.');
    });

    test('falls back when detail is present but blank', () {
      final response = _jsonResponse({'detail': '   '}, 400);

      final result = extractErrorDetail(response, fallback: 'fallback');

      expect(result, 'fallback');
    });

    test('falls back when the JSON body is a list, not an object', () {
      final response = http.Response(jsonEncode(['unexpected', 'array']), 400);

      final result = extractErrorDetail(response, fallback: 'fallback');

      expect(result, 'fallback');
    });

    test('falls back when detail is present but not a string', () {
      final response = _jsonResponse({'detail': 42}, 400);

      final result = extractErrorDetail(response, fallback: 'fallback');

      expect(result, 'fallback');
    });
  });
}
