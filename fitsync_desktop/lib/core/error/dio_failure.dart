import 'package:dio/dio.dart';

import 'failures.dart';

/// Turns a Dio error into a [ServerFailure] carrying the API's own message and
/// its stable error code.
///
/// The API answers a broken business rule with `{ "error": "TIME_CONFLICT",
/// "message": "..." }`. Calling `toString()` on that map put the whole envelope
/// — braces, trace id and all — on screen, and threw the code away, so the UI
/// had nothing to branch on and nothing to translate. Parsing it once here
/// keeps both.
ServerFailure failureFrom(DioException e, [String fallback = 'Zahtjev nije uspio.']) {
  final data = e.response?.data;
  if (data is Map) {
    final code = data['error']?.toString();
    final message = data['message']?.toString();
    if (message != null && message.isNotEmpty) return ServerFailure(message, code);

    // ASP.NET model validation answers with { errors: { Field: ["..."] } }.
    if (data['errors'] is Map) {
      final first = (data['errors'] as Map).values.first;
      if (first is List && first.isNotEmpty) {
        return ServerFailure(first.first.toString(), code);
      }
    }
    if (code != null) return ServerFailure(code, code);
  }
  return ServerFailure(e.message ?? fallback);
}
