import 'package:flutter/material.dart';

import '../../data/models/stock_quote.dart';

class QuoteTile extends StatelessWidget {
  const QuoteTile({super.key, required this.quote});

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final isPositive = quote.change >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    return ListTile(
      title: Text(
        quote.ticker,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Prev close: ${quote.previousClose.toStringAsFixed(2)}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            quote.price.toStringAsFixed(2),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            '${quote.change.toStringAsFixed(2)} (${quote.changePercent.toStringAsFixed(2)}%)',
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
