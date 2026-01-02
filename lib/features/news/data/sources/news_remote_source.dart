import 'dart:convert';

import '../../../../app/config/env.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/news_article.dart';

class NewsRemoteSource {
  NewsRemoteSource({ApiClient? client}) : _client = client ?? const ApiClient();

  final ApiClient _client;

  Future<List<NewsArticle>> fetchLatest({String query = 'stocks'}) async {
    final uri = Uri.parse('${ApiEndpoints.newsBaseUrl}/everything').replace(
      queryParameters: <String, String>{
        'q': query,
        'pageSize': '20',
        'sortBy': 'publishedAt',
        'language': 'en',
        'apiKey': Env.newsApiKey,
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Unable to load news: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final articles = (body['articles'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return articles.map(NewsArticle.fromJson).toList();
  }
}
