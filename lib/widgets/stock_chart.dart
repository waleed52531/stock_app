import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/market_candle.dart';

class StockChart extends StatelessWidget {
  const StockChart({super.key, required this.candles});

  final List<MarketCandle> candles;

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return const Center(child: Text('No data yet'));
    }
    final minY = candles.map((c) => c.close).reduce((a, b) => a < b ? a : b);
    final maxY = candles.map((c) => c.close).reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        minY: minY * 0.995,
        maxY: maxY * 1.005,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: candles
                .map((c) => FlSpot(c.time.millisecondsSinceEpoch.toDouble(), c.close))
                .toList(),
            dotData: const FlDotData(show: false),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
