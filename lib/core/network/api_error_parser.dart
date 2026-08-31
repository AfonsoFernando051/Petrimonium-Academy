import 'dart:convert';
import 'package:http/http.dart' as http;

/// Extracts a human-readable reason from a backend error response.
///
/// The backend's `GlobalExceptionHandler` always returns a JSON body shaped
/// like RFC 7807 `ProblemDetail` for non-2xx responses — e.g.
/// `{"detail": "password: must be at least 8 characters", "status": 400, ...}`.
/// Discarding that body and surfacing only the HTTP status code (as in
/// `"Failed to register. Status Code: 400"`) throws away the one piece of
/// information that actually tells the user what to fix.
///
/// Falls back to [fallback] when the body is empty, isn't JSON (e.g. an
/// HTML error page from a proxy), or has no usable `detail` field — never
/// throws itself.
String extractErrorDetail(http.Response response, {required String fallback}) {
  if (response.body.trim().isEmpty) return fallback;

  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
    }
  } catch (_) {
    // Not JSON — fall through to the generic fallback below.
  }

  return fallback;
}
