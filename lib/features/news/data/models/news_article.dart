class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.source,
    required this.url,
    required this.publishedAt,
    required this.imageUrl,
  });

  final String title;
  final String source;
  final String url;
  final DateTime publishedAt;
  final String? imageUrl;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'Untitled',
      source: (json['source']?['name'] as String?) ?? 'Unknown source',
      url: json['url'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      imageUrl: json['urlToImage'] as String?,
    );
  }
}
