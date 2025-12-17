import 'package:flutter/material.dart';
import '../models/stock_quote.dart';
import '../services/polygon_service.dart';
import '../widgets/quote_tile.dart';

class MarketTab extends StatefulWidget {
  const MarketTab({super.key});

  @override
  State<MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<MarketTab> {
  late Future<List<StockQuote>> _pakistanQuotes;
  late Future<List<StockQuote>> _globalQuotes;

  @override
  void initState() {
    super.initState();
    _pakistanQuotes = PolygonService.fetchWatchlist(
      const ['OGDC', 'HBL', 'PSO'],
      locale: 'pk',
    );
    _globalQuotes = PolygonService.fetchWatchlist(
      const ['AAPL', 'MSFT', 'GOOGL', 'NVDA'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _pakistanQuotes = PolygonService.fetchWatchlist(
            const ['OGDC', 'HBL', 'PSO'],
            locale: 'pk',
          );
          _globalQuotes = PolygonService.fetchWatchlist(
            const ['AAPL', 'MSFT', 'GOOGL', 'NVDA'],
          );
        });
        await Future.wait([_pakistanQuotes, _globalQuotes]);
      },
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Pakistan (PSX)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<StockQuote>>(
            future: _pakistanQuotes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
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
              'Global (US)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<StockQuote>>(
            future: _globalQuotes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
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
