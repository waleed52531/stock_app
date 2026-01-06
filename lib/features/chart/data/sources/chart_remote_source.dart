import 'dart:convert';

import '../../../../app/config/env.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/helpers.dart';
import '../models/market_candle.dart';

class ChartRemoteSource {
  ChartRemoteSource({ApiClient? client}) : _client = client ?? const ApiClient();

  final ApiClient _client;

  void _ensureApiKey() {
    if (Env.polygonApiKey.trim().isEmpty) {
      throw Exception(
        'Twelve Data API key is missing. Provide --dart-define=POLYGON_API_KEY=YOUR_KEY.',
      );
    }
  }

  Future<List<MarketCandle>> fetchIntradaySeries(String ticker) async {
    _ensureApiKey();
    final uri = Uri.parse(
      '${ApiEndpoints.polygonBaseUrl}/time_series',
    ).replace(queryParameters: <String, String>{
      'symbol': ticker,
      'interval': '5min',
      'outputsize': '120',
      'apikey': Env.polygonApiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      final message = extractApiMessage(response.body);
      final status = response.statusCode;
      final reason = message.isNotEmpty ? ': $message' : '';
      throw Exception('Unable to load chart data: $status$reason');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final values =
        (body['values'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return values.map(MarketCandle.fromTwelveData).toList().reversed.toList();
  }
}
