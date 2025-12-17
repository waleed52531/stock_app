import 'dart:convert';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/market_candle.dart';
import '../models/sector_performance.dart';
import '../models/stock_quote.dart';

class PolygonService {
  static const _baseUrl = 'https://api.polygon.io';
  static Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer ${ApiConfig.polygonApiKey}',
      };

  static Future<List<StockQuote>> fetchWatchlist(
    List<String> tickers, {
    String locale = 'us',
    String market = 'stocks',
  }) async {
    final joinedTickers = tickers.join(',');
    final uri = Uri.parse(
      '$_baseUrl/v2/snapshot/locale/$locale/markets/$market/tickers',
    ).replace(queryParameters: <String, String>{
      'tickers': joinedTickers,
      'apiKey': ApiConfig.polygonApiKey,
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
      'apiKey': ApiConfig.polygonApiKey,
    });

    final response = await http.get(uri, headers: _authHeaders);
    if (response.statusCode != 200) {
      throw Exception('Unable to load chart data: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return results.map(MarketCandle.fromAgg).toList();
  }

  static Future<SectorPerformance> fetchSectorPerformance(
    String sectorName,
    String representativeTicker,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/v2/aggs/ticker/$representativeTicker/prev',
    ).replace(queryParameters: <String, String>{
      'adjusted': 'true',
      'apiKey': ApiConfig.polygonApiKey,
    });

    final response = await http.get(uri, headers: _authHeaders);
    if (response.statusCode != 200) {
      throw Exception('Unable to load performance for $sectorName');
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
}
