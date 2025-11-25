import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../ssrf/ssrf.dart';
import 'common_widgets.dart';
import 'divesitedetail_widget.dart';

class DiveSiteCardWidget extends StatelessWidget {
  final Divesite divesite;
  final List<Dive> allDives;
  final List<Divesite> diveSites;

  const DiveSiteCardWidget({
    super.key,
    required this.divesite,
    required this.allDives,
    required this.diveSites,
  });

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
              builder: (context) => DiveSiteDetailScreen(
                divesite: divesite,
                dives: siteDives,
                diveSites: diveSites,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview (only if position exists)
            if (divesite.position != null)
              SizedBox(
                height: 150,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(divesite.position!.lat, divesite.position!.lon),
                    initialZoom: 13.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none, // Disable interactions
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'net.kastelo.yadl',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(divesite.position!.lat, divesite.position!.lon),
                          width: 30,
                          height: 30,
                          child: Icon(
                            Icons.location_pin,
                            size: 30,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Site information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dive Site',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
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
