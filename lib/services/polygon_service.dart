import 'dart:convert';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/market_candle.dart';
import '../models/sector_performance.dart';
import '../models/stock_quote.dart';

class PolygonService {
  static const _baseUrl = 'https://api.polygon.io';
  static String get _apiKey => ApiConfig.polygonApiKey;
  static Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer ${ApiConfig.polygonApiKey}',
      };

  static void _ensureApiKey() {
    if (_apiKey.trim().isEmpty) {
      throw Exception(
        'Polygon API key is missing. Provide --dart-define=POLYGON_API_KEY=YOUR_KEY.',
      );
    }
  }

  static Future<List<StockQuote>> fetchWatchlist(
    List<String> tickers, {
    String locale = 'us',
    String market = 'stocks',
  }) async {
    _ensureApiKey();
    final joinedTickers = tickers.join(',');
    final uri = Uri.parse(
      '$_baseUrl/v2/snapshot/locale/$locale/markets/$market/tickers',
    ).replace(queryParameters: <String, String>{
      'tickers': joinedTickers,
      'apiKey': _apiKey,
    });

    final response = await http.get(uri, headers: _authHeaders);
    if (response.statusCode != 200) {
      final isAuthError = response.statusCode == 401 || response.statusCode == 403;
      final reason = isAuthError
          ? 'Check Polygon API key or plan permissions.'
          : 'Unexpected response.';
      throw Exception('Unable to load watchlist: ${response.statusCode} ($reason)');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['tickers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return results.map(StockQuote.fromSnapshotJson).toList();
  }

  static Future<List<MarketCandle>> fetchIntradaySeries(String ticker) async {
    _ensureApiKey();
    final now = DateTime.now().toUtc();
    final from = now.subtract(const Duration(hours: 6));
    final fromMillis = from.millisecondsSinceEpoch;
    final toMillis = now.millisecondsSinceEpoch;
    final uri = Uri.parse(
      '$_baseUrl/v2/aggs/ticker/$ticker/range/5/minute/$fromMillis/$toMillis',
    ).replace(queryParameters: <String, String>{
      'adjusted': 'true',
      'sort': 'asc',
      'limit': '120',
      'apiKey': _apiKey,
    });

    final response = await http.get(uri, headers: _authHeaders);
    if (response.statusCode != 200) {
      final message = _extractMessage(response.body);
      final status = response.statusCode;
      final reason = message.isNotEmpty ? ': $message' : '';
      throw Exception('Unable to load chart data: $status$reason');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return results.map(MarketCandle.fromAgg).toList();
  }

  static Future<SectorPerformance> fetchSectorPerformance(
    String sectorName,
    String representativeTicker,
  ) async {
    _ensureApiKey();
    final uri = Uri.parse(
      '$_baseUrl/v2/aggs/ticker/$representativeTicker/prev',
    ).replace(queryParameters: <String, String>{
      'adjusted': 'true',
      'apiKey': _apiKey,
    });

    final response = await http.get(uri, headers: _authHeaders);
    if (response.statusCode != 200) {
      final message = _extractMessage(response.body);
      final reason = message.isNotEmpty ? ': $message' : '';
      throw Exception('Unable to load performance for $sectorName$reason');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final first = results.isNotEmpty ? results.first : <String, dynamic>{};
    final close = (first['c'] ?? 0).toDouble();
    final open = (first['o'] ?? close).toDouble();
    final changePercent = open == 0 ? 0.0 : ((close - open) / open) * 100;

    return SectorPerformance(
      name: sectorName,
      changePercent: changePercent,
      representativeTicker: representativeTicker,
    );
  }

  static String _extractMessage(String body) {
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
}
