import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../ssrf/ssrf.dart';
import 'depth_profile_widget.dart';

class DiveDetailScreen extends StatelessWidget {
  final Dive dive;

  const DiveDetailScreen({super.key, required this.dive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Dive #${dive.number}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context, 'General Information', [
                _buildInfoRow('Date', DateFormat('yyyy-MM-dd').format(dive.start)),
                _buildInfoRow('Time', DateFormat('HH:mm:ss').format(dive.start)),
                _buildInfoRow('Duration', _formatDuration(dive.duration)),
                if (dive.rating != null) _buildInfoRow('Rating', '★' * dive.rating!),
                if (dive.tags.isNotEmpty) _buildInfoRow('Tags', dive.tags.join(', ')),
              ]),
              const SizedBox(height: 16),
              if (dive.divecomputers.isNotEmpty) ...[
                _buildInfoCard(context, 'Dive Computer Data', [
                  _buildInfoRow('Max Depth', '${dive.divecomputers[0].maxDepth.toStringAsFixed(1)} m'),
                  _buildInfoRow('Mean Depth', '${dive.divecomputers[0].meanDepth.toStringAsFixed(1)} m'),
                  if (dive.divecomputers[0].environment?.airTemperature != null)
                    _buildInfoRow('Air Temperature', '${dive.divecomputers[0].environment!.airTemperature!.toStringAsFixed(1)} °C'),
                  if (dive.divecomputers[0].environment?.waterTemperature != null)
                    _buildInfoRow('Water Temperature', '${dive.divecomputers[0].environment!.waterTemperature!.toStringAsFixed(1)} °C'),
                ]),
                const SizedBox(height: 16),
                if (dive.divecomputers[0].samples.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Depth Profile',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          DepthProfileWidget(diveComputer: dive.divecomputers[0]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              if (dive.sac != null || dive.otu != null || dive.cns != null) ...[
                _buildInfoCard(context, 'Physiological Data', [
                  if (dive.sac != null) _buildInfoRow('SAC', '${dive.sac!.toStringAsFixed(1)} l/min'),
                  if (dive.otu != null) _buildInfoRow('OTU', dive.otu.toString()),
                  if (dive.cns != null) _buildInfoRow('CNS', '${dive.cns}%'),
                ]),
                const SizedBox(height: 16),
              ],
              if (dive.divemaster != null || dive.buddies.isNotEmpty) ...[
                _buildInfoCard(context, 'People', [
                  if (dive.divemaster != null) _buildInfoRow('Divemaster', dive.divemaster!),
                  if (dive.buddies.isNotEmpty) _buildInfoRow('Buddies', dive.buddies.join(', ')),
                ]),
                const SizedBox(height: 16),
              ],
              if (dive.cylinders.isNotEmpty) ...[
                _buildInfoCard(context, 'Cylinders',
                  dive.cylinders.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final cyl = entry.value;
                    final desc = cyl.description ?? 'Cylinder ${idx + 1}';
                    final details = <String>[];
                    if (cyl.size != null) details.add('${cyl.size!.toStringAsFixed(1)} l');
                    if (cyl.workpressure != null) details.add('${cyl.workpressure!.toStringAsFixed(0)} bar');
                    if (cyl.start != null) details.add('Start: ${cyl.start!.toStringAsFixed(0)} bar');
                    if (cyl.end != null) details.add('End: ${cyl.end!.toStringAsFixed(0)} bar');
                    return _buildInfoRow(desc, details.join(', '));
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (dive.weightsystems.isNotEmpty) ...[
                _buildInfoCard(context, 'Weight Systems',
                  dive.weightsystems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ws = entry.value;
                    final desc = ws.description ?? 'Weight ${idx + 1}';
                    final weight = ws.weight != null ? '${ws.weight!.toStringAsFixed(1)} kg' : '';
                    return _buildInfoRow(desc, weight);
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (dive.notes != null && dive.notes!.isNotEmpty) ...[
                _buildInfoCard(context, 'Notes', [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(dive.notes!, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ]),
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
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).round();
    return '$minutes:${secs.toString().padLeft(2, '0')} min';
  }
}
