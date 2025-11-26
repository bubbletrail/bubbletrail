import 'package:flutter/material.dart';

import '../ssrf/ssrf.dart';
import 'common_widgets.dart';
import 'divesitedetail_widget.dart';

class DiveSiteCardWidget extends StatelessWidget {
  final Divesite divesite;
  final List<Dive> allDives;
  final List<Divesite> diveSites;

  const DiveSiteCardWidget({super.key, required this.divesite, required this.allDives, required this.diveSites});

  @override
  Widget build(BuildContext context) {
    // Filter dives for this site
    final siteDives = allDives.where((d) => d.divesiteid?.trim() == divesite.uuid.trim()).toList();

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiveSiteDetailScreen(divesite: divesite, dives: siteDives, diveSites: diveSites),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview (only if position exists)
            if (divesite.position != null) SizedBox(height: 150, child: DiveSiteMap(position: divesite.position!)),
            // Site information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Dive Site', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                  const Divider(),
                  buildInfoRow('Name', divesite.name),
                  if (divesite.position != null) ...[
                    buildInfoRow('Latitude', divesite.position!.lat.toStringAsFixed(6)),
                    buildInfoRow('Longitude', divesite.position!.lon.toStringAsFixed(6)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
