import 'dart:convert';

import 'package:intl/intl.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₨', decimalDigits: 2);
final NumberFormat _percentFormat = NumberFormat('0.00');

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

String formatCurrency(double value) {
  return _currencyFormat.format(value);
}

String formatDelta(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${_currencyFormat.format(value)}';
}

String formatPercent(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${_percentFormat.format(value)}%';
}
