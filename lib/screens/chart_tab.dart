import 'package:flutter/material.dart';
import '../models/market_candle.dart';
import '../services/polygon_service.dart';
import '../widgets/stock_chart.dart';

class ChartTab extends StatefulWidget {
  const ChartTab({super.key});

  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  final _controller = TextEditingController(text: 'AAPL');
  Future<List<MarketCandle>>? _seriesFuture;

  @override
  void initState() {
    super.initState();
    _seriesFuture = PolygonService.fetchIntradaySeries(_controller.text.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _load() {
    final ticker = _controller.text.trim();
    if (ticker.isEmpty) {
      return;
    }
    setState(() {
      _seriesFuture = PolygonService.fetchIntradaySeries(ticker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Ticker (e.g. OGDC for PSX, AAPL for NASDAQ)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _load,
              ),
            ),
            onSubmitted: (_) => _load(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<MarketCandle>>(
              future: _seriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Chart error: ${snapshot.error}'));
                }
                final candles = snapshot.data ?? [];
                return StockChart(candles: candles);
              },
            ),
          ),
        ],
      ),
    );
  }
}
