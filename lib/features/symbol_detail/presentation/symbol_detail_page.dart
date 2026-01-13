import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/chart_range.dart';
import '../../../core/models/quote.dart';
import '../../../core/models/time_series_point.dart';
import '../../../core/utils/helpers.dart';

class SymbolDetailPage extends StatefulWidget {
  const SymbolDetailPage({
    super.key,
    required this.symbol,
    required this.displayName,
    this.initialQuote,
  });

  final String symbol;
  final String displayName;
  final Quote? initialQuote;

  @override
  State<SymbolDetailPage> createState() => _SymbolDetailPageState();
}

class _SymbolDetailPageState extends State<SymbolDetailPage> {
  ChartRange _selectedRange = ChartRange.oneMonth;
  bool _isLoading = false;
  List<TimeSeriesPoint> _points = [];

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    setState(() {
      _isLoading = true;
    });
    final repository = AppScope.of(context).repository;
    final points = await repository.fetchTimeSeries(widget.symbol, _selectedRange);
    if (!mounted) {
      return;
    }
    setState(() {
      _points = points;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.initialQuote;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.symbol} · ${widget.displayName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.eodLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            _QuoteHeader(quote: quote),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ChartRange.values
                  .map(
                    (range) => ChoiceChip(
                      label: Text(range.label),
                      selected: _selectedRange == range,
                      onSelected: (selected) {
                        if (!selected) {
                          return;
                        }
                        setState(() {
                          _selectedRange = range;
                        });
                        _loadSeries();
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _points.isEmpty
                      ? Center(
                          child: Text(
                            AppStrings.chartNoData,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : _Chart(points: _points),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteHeader extends StatelessWidget {
  const _QuoteHeader({required this.quote});

  final Quote? quote;

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return Text(
        '--',
        style: Theme.of(context).textTheme.headlineMedium,
      );
    }
    final changeColor = quote!.change >= 0 ? Colors.green : Colors.redAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCurrency(quote!.close),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${formatDelta(quote!.change)} (${formatPercent(quote!.changePercent)})',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: changeColor),
        ),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.points});

  final List<TimeSeriesPoint> points;

  @override
  Widget build(BuildContext context) {
    final spots = points
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            entry.value.close,
          ),
        )
        .toList();

    final minY = points.map((p) => p.close).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.close).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: minY - 2,
        maxY: maxY + 2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Theme.of(context).colorScheme.primary,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
