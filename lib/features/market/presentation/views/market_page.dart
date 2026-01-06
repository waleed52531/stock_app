import 'package:flutter/material.dart';

import '../../../../app/config/env.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/stock_quote.dart';
import '../../data/sources/market_remote_source.dart';
import '../widgets/market_widgets.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final MarketRemoteSource _remoteSource = MarketRemoteSource();
  late Future<List<StockQuote>> _pakistanQuotes;
  late Future<List<StockQuote>> _globalQuotes;

  bool get _hasApiKey => Env.polygonApiKey.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pakistanQuotes = _loadPakistanQuotes();
    _globalQuotes = _loadGlobalQuotes();
  }

  Future<List<StockQuote>> _loadPakistanQuotes() {
    if (!_hasApiKey) {
      return Future.value([]);
    }
    return _remoteSource.fetchWatchlist(
      const ['OGDC', 'HBL', 'PSO'],
      locale: 'pk',
    );
  }

  Future<List<StockQuote>> _loadGlobalQuotes() {
    if (!_hasApiKey) {
      return Future.value([]);
    }
    return _remoteSource.fetchWatchlist(
      const ['AAPL', 'MSFT', 'GOOGL', 'NVDA'],
    );
  }

  Widget _buildMissingKeyMessage() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Polygon API key is missing. Add --dart-define=POLYGON_API_KEY=YOUR_KEY to load market data.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _pakistanQuotes = _loadPakistanQuotes();
          _globalQuotes = _loadGlobalQuotes();
        });
        await Future.wait([_pakistanQuotes, _globalQuotes]);
      },
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              AppStrings.pakistanSection,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<StockQuote>>(
            future: _pakistanQuotes,
            builder: (context, snapshot) {
              if (!_hasApiKey) {
                return _buildMissingKeyMessage();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Failed to load PSX data: ${snapshot.error}'),
                );
              }
              final quotes = snapshot.data ?? [];
              return Column(
                children: quotes.map((q) => QuoteTile(quote: q)).toList(),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              AppStrings.globalSection,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<StockQuote>>(
            future: _globalQuotes,
            builder: (context, snapshot) {
              if (!_hasApiKey) {
                return _buildMissingKeyMessage();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Failed to load US data: ${snapshot.error}'),
                );
              }
              final quotes = snapshot.data ?? [];
              return Column(
                children: quotes.map((q) => QuoteTile(quote: q)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
