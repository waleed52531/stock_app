import 'dart:convert';

import '../../../../app/config/env.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/helpers.dart';
import '../models/stock_quote.dart';

class MarketRemoteSource {
  MarketRemoteSource({ApiClient? client}) : _client = client ?? const ApiClient();

  final ApiClient _client;

  void _ensureApiKey() {
    if (Env.polygonApiKey.trim().isEmpty) {
      throw Exception(
        'Polygon API key is missing. Provide --dart-define=POLYGON_API_KEY=YOUR_KEY.',
      );
    }
  }

  Future<List<StockQuote>> fetchWatchlist(
    List<String> tickers, {
    String locale = 'us',
    String market = 'stocks',
  }) async {
    _ensureApiKey();
    if (locale.toLowerCase() != 'us') {
      throw Exception(
        'Polygon does not provide $locale market snapshots. Use a PSX data provider or remove this section.',
      );
    }
    final results = await Future.wait(
      tickers.map((ticker) async {
        final uri = Uri.parse(
          '${ApiEndpoints.polygonBaseUrl}/v2/aggs/ticker/$ticker/prev',
        ).replace(queryParameters: <String, String>{
          'adjusted': 'true',
          'apiKey': Env.polygonApiKey,
        });

        final response = await _client.get(uri);
        if (response.statusCode != 200) {
          final isAuthError =
              response.statusCode == 401 || response.statusCode == 403;
          final message = extractApiMessage(response.body);
          final reason = isAuthError
              ? 'Check Polygon API key or plan permissions for aggregate data.'
              : 'Unexpected response.';
          final detail = message.isNotEmpty ? ' ${message.trim()}' : '';
          throw Exception(
            'Unable to load watchlist: ${response.statusCode} ($reason)$detail',
          );
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final aggregates =
            (body['results'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        final first = aggregates.isNotEmpty ? aggregates.first : <String, dynamic>{};
        return StockQuote.fromPreviousAgg(ticker, first);
      }),
    );

    return results;
  }

  Future<List<dynamic>> fetchIntradaySeriesRaw(String ticker) async {
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

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      final message = extractApiMessage(response.body);
      final status = response.statusCode;
      final reason = message.isNotEmpty ? ': $message' : '';
      throw Exception('Unable to load chart data: $status$reason');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return results.map((entry) => (entry['c'] ?? 0).toDouble()).toList();
  }
}
