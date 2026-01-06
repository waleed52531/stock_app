import 'dart:convert';

import '../../../../app/config/env.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/helpers.dart';
import '../models/sector_performance.dart';

class SectorRemoteSource {
  SectorRemoteSource({ApiClient? client}) : _client = client ?? const ApiClient();

  final ApiClient _client;

  void _ensureApiKey() {
    if (Env.polygonApiKey.trim().isEmpty) {
      throw Exception(
        'Twelve Data API key is missing. Provide --dart-define=POLYGON_API_KEY=YOUR_KEY.',
      );
    }
  }

  Future<SectorPerformance> fetchSectorPerformance(
    String sectorName,
    String representativeTicker,
  ) async {
    _ensureApiKey();
    final uri = Uri.parse(
      '${ApiEndpoints.polygonBaseUrl}/quote',
    ).replace(queryParameters: <String, String>{
      'symbol': representativeTicker,
      'apikey': Env.polygonApiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      final message = extractApiMessage(response.body);
      final reason = message.isNotEmpty ? ': $message' : '';
      throw Exception('Unable to load performance for $sectorName$reason');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    final quote = data is List
        ? (data.isNotEmpty ? data.first as Map<String, dynamic> : <String, dynamic>{})
        : (data is Map<String, dynamic> ? data : body);
    final close =
        double.tryParse(quote['close']?.toString() ?? '') ?? 0;
    final open =
        double.tryParse(quote['open']?.toString() ?? '') ?? close;
    final changePercent = open == 0 ? 0.0 : ((close - open) / open) * 100;

    return SectorPerformance(
      name: sectorName,
      changePercent: changePercent,
      representativeTicker: representativeTicker,
    );
  }
}
