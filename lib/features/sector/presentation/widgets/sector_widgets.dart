import 'package:flutter/material.dart';

import '../../data/models/sector_performance.dart';

class SectorTile extends StatelessWidget {
  const SectorTile({super.key, required this.performance});

  final SectorPerformance performance;

  @override
  Widget build(BuildContext context) {
    final isPositive = performance.changePercent >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performance.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Lead: ${performance.representativeTicker}'),
                ],
              ),
            ),
            Text(
              '${performance.changePercent.toStringAsFixed(2)}%',
              style: TextStyle(color: color, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
