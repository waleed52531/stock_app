import 'dart:convert';

import '../../../../app/config/env.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/helpers.dart';
import '../models/market_candle.dart';

class ChartRemoteSource {
  ChartRemoteSource({ApiClient? client}) : _client = client ?? const ApiClient();

  final ApiClient _client;

  static Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer ${Env.polygonApiKey}',
      };

  void _ensureApiKey() {
    if (Env.polygonApiKey.trim().isEmpty) {
      throw Exception(
        'Polygon API key is missing. Provide --dart-define=POLYGON_API_KEY=YOUR_KEY.',
      );
    }
  }

  Future<List<MarketCandle>> fetchIntradaySeries(String ticker) async {
    _ensureApiKey();
    final now = DateTime.now().toUtc();
    final from = now.subtract(const Duration(hours: 6));
    final fromMillis = from.millisecondsSinceEpoch;
    final toMillis = now.millisecondsSinceEpoch;
    final uri = Uri.parse(
      '${ApiEndpoints.polygonBaseUrl}/v2/aggs/ticker/$ticker/range/5/minute/$fromMillis/$toMillis',
    ).replace(queryParameters: <String, String>{
      'adjusted': 'true',
      'sort': 'asc',
      'limit': '120',
      'apiKey': Env.polygonApiKey,
    });

    final response = await _client.get(uri, headers: _authHeaders);
    if (response.statusCode != 200) {
      final message = extractApiMessage(response.body);
      final status = response.statusCode;
      final reason = message.isNotEmpty ? ': $message' : '';
      throw Exception('Unable to load chart data: $status$reason');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return results.map(MarketCandle.fromAgg).toList();
  }
}
