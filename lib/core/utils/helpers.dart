import 'dart:convert';

String extractApiMessage(String body) {
  try {
    final decoded = body.isNotEmpty ? jsonDecode(body) : {};
    if (decoded is Map<String, dynamic>) {
      final message = decoded['error'] ?? decoded['message'];
      return message == null ? '' : message.toString();
    }
  } catch (_) {
    // Ignore JSON parsing errors and fall back to an empty message.
  }
  return '';
}
