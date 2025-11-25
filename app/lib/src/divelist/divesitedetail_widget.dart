import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../ssrf/ssrf.dart';
import 'divedetail_widget.dart';

class DiveSiteDetailScreen extends StatelessWidget {
  final Divesite divesite;
  final List<Dive> dives;

  const DiveSiteDetailScreen({super.key, required this.divesite, required this.dives});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(divesite.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context, 'Location Information', [
                _buildInfoRow('Name', divesite.name),
                if (divesite.position != null) ...[
                  _buildInfoRow('Latitude', divesite.position!.lat.toStringAsFixed(6)),
                  _buildInfoRow('Longitude', divesite.position!.lon.toStringAsFixed(6)),
                ],
                _buildInfoRow('UUID', divesite.uuid),
              ]),
              const SizedBox(height: 16),
              if (dives.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dives at this site (${dives.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Dive #')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Time')),
                              DataColumn(label: Text('Max Depth (m)')),
                              DataColumn(label: Text('Duration')),
                            ],
                            dividerThickness: 0,
                            dataRowMinHeight: 24,
                            dataRowMaxHeight: 32,
                            rows: dives.map((dive) {
                              final maxDepth = dive.divecomputers.isNotEmpty ? dive.divecomputers[0].maxDepth : 0.0;

                              return DataRow(
                                onSelectChanged: (selected) {
                                  if (selected == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DiveDetailScreen(dive: dive),
                                      ),
                                    );
                                  }
                                },
                                cells: [
                                  DataCell(Text(dive.number.toString())),
                                  DataCell(Text(DateFormat('yyyy-MM-dd').format(dive.start))),
                                  DataCell(Text(DateFormat('HH:mm').format(dive.start))),
                                  DataCell(Text(maxDepth.toStringAsFixed(1))),
                                  DataCell(Text(_formatDuration(dive.duration))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No dives recorded at this site',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    return '$minutes min';
  }
}
