import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/news_article.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final published = DateFormat('MMM d, h:mm a').format(article.publishedAt.toLocal());
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        leading: article.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.article_outlined),
        title: Text(article.title),
        subtitle: Text('${article.source} • $published'),
        onTap: () => _openUrl(context),
      ),
    );
  }

  void _openUrl(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open in browser: ${article.url}')),
    );
  }
}
