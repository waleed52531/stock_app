import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../data/models/market_candle.dart';
import '../../data/sources/chart_remote_source.dart';
import '../widgets/chart_widgets.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final _controller = TextEditingController(text: 'AAPL');
  final ChartRemoteSource _remoteSource = ChartRemoteSource();
  Future<List<MarketCandle>>? _seriesFuture;

  @override
  void initState() {
    super.initState();
    _seriesFuture = _remoteSource.fetchIntradaySeries(_controller.text.trim());
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
      _seriesFuture = _remoteSource.fetchIntradaySeries(ticker);
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
              labelText: AppStrings.chartLabel,
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
