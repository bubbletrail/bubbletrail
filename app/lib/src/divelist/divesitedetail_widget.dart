import 'package:flutter/material.dart';

import '../ssrf/ssrf.dart';
import 'common_widgets.dart';
import 'dive_table_widget.dart';
import 'divesite_map_widget.dart';

class DiveSiteDetailScreen extends StatelessWidget {
  final Divesite divesite;
  final List<Dive> dives;
  final List<Divesite> diveSites;

  const DiveSiteDetailScreen({super.key, required this.divesite, required this.dives, required this.diveSites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(divesite.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoCard(context, 'Location Information', [
                buildInfoRow('Name', divesite.name),
                if (divesite.position != null) ...[
                  buildInfoRow('Latitude', divesite.position!.lat.toStringAsFixed(6)),
                  buildInfoRow('Longitude', divesite.position!.lon.toStringAsFixed(6)),
                ],
                buildInfoRow('UUID', divesite.uuid),
              ]),
              const SizedBox(height: 16),
              DiveSiteMapWidget(divesite: divesite),
              const SizedBox(height: 16),
              if (dives.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dives at this site (${dives.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const Divider(),
                        DiveTableWidget(dives: dives, diveSites: diveSites, showSiteColumn: false),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No dives recorded at this site', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
