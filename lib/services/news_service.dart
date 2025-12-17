import 'dart:convert';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/news_article.dart';

class NewsService {
  static const _baseUrl = 'https://newsapi.org/v2';

  static Future<List<NewsArticle>> fetchLatest({String query = 'stocks'}) async {
    final uri = Uri.parse('$_baseUrl/everything').replace(
      queryParameters: <String, String>{
        'q': query,
        'pageSize': '20',
        'sortBy': 'publishedAt',
        'language': 'en',
        'apiKey': ApiConfig.newsApiKey,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Unable to load news: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final articles = (body['articles'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return articles.map(NewsArticle.fromJson).toList();
  }
}
