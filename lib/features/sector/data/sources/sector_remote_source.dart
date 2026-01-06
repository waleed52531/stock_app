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
        'Polygon API key is missing. Provide --dart-define=POLYGON_API_KEY=YOUR_KEY.',
      );
    }
  }

  Future<SectorPerformance> fetchSectorPerformance(
    String sectorName,
    String representativeTicker,
  ) async {
    _ensureApiKey();
    final uri = Uri.parse(
      '${ApiEndpoints.polygonBaseUrl}/v2/aggs/ticker/$representativeTicker/prev',
    ).replace(queryParameters: <String, String>{
      'adjusted': 'true',
      'apiKey': Env.polygonApiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      final message = extractApiMessage(response.body);
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
}
