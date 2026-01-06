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
        'Twelve Data API key is missing. Provide --dart-define=POLYGON_API_KEY=YOUR_KEY.',
      );
    }
  }

  // ignore: unused_parameter
  Future<List<StockQuote>> fetchWatchlist(
    List<String> tickers, {
    String locale = 'us',
    String market = 'stocks',
  }) async {
    _ensureApiKey();
    final uri = Uri.parse('${ApiEndpoints.polygonBaseUrl}/quote')
        .replace(queryParameters: <String, String>{
      'symbol': tickers.join(','),
      'apikey': Env.polygonApiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      final message = extractApiMessage(response.body);
      final reason = message.isNotEmpty ? ': $message' : '';
      throw Exception('Unable to load watchlist: ${response.statusCode}$reason');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(StockQuote.fromTwelveDataQuote)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      return [StockQuote.fromTwelveDataQuote(data)];
    }
    if (body.isNotEmpty) {
      return [StockQuote.fromTwelveDataQuote(body)];
    }
    return [];
  }

  Future<List<dynamic>> fetchIntradaySeriesRaw(String ticker) async {
    _ensureApiKey();
    final now = DateTime.now().toUtc();
    final from = now.subtract(const Duration(hours: 6));
    final fromMillis = from.millisecondsSinceEpoch;
    final toMillis = now.millisecondsSinceEpoch;
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
    return values
        .map((entry) => double.tryParse(entry['close']?.toString() ?? '') ?? 0)
        .toList()
        .reversed
        .toList();
  }
}
