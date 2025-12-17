import 'package:flutter/material.dart';
import '../models/sector_performance.dart';
import '../services/polygon_service.dart';
import '../widgets/sector_tile.dart';

class SectorTab extends StatefulWidget {
  const SectorTab({super.key});

  @override
  State<SectorTab> createState() => _SectorTabState();
}

class _SectorTabState extends State<SectorTab> {
  final Map<String, String> _sectorLeads = const {
    'Technology (US)': 'AAPL',
    'Energy (Pakistan)': 'OGDC',
    'Finance (US)': 'JPM',
    'Materials (Pakistan)': 'LUCK',
    'Semiconductors (US)': 'NVDA',
  };

  late Future<List<SectorPerformance>> _sectorFuture;

  @override
  void initState() {
    super.initState();
    _sectorFuture = _load();
  }

  Future<List<SectorPerformance>> _load() async {
    final entries = await Future.wait(
      _sectorLeads.entries
          .map((entry) => PolygonService.fetchSectorPerformance(entry.key, entry.value)),
    );
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _sectorFuture = _load();
        });
        await _sectorFuture;
      },
      child: FutureBuilder<List<SectorPerformance>>(
        future: _sectorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Sector error: ${snapshot.error}'));
          }
          final sectors = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sectors.length,
            itemBuilder: (context, index) => SectorTile(performance: sectors[index]),
          );
        },
      ),
    );
  }
}
