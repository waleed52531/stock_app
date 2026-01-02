import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../data/models/news_article.dart';
import '../../data/sources/news_remote_source.dart';
import '../widgets/news_widgets.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsRemoteSource _remoteSource = NewsRemoteSource();
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _remoteSource.fetchLatest(query: 'stocks OR Pakistan market');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _newsFuture = _remoteSource.fetchLatest(query: 'stocks OR Pakistan market');
        });
        await _newsFuture;
      },
      child: FutureBuilder<List<NewsArticle>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('News error: ${snapshot.error}'));
          }
          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return const Center(child: Text(AppStrings.emptyNews));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: articles.length,
            itemBuilder: (context, index) => NewsCard(article: articles[index]),
          );
        },
      ),
    );
  }
}
