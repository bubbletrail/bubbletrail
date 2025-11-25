import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../ssrf/ssrf.dart';

class DiveSiteMapWidget extends StatelessWidget {
  final Divesite divesite;
  final double height;

  const DiveSiteMapWidget({super.key, required this.divesite, this.height = 300});

  @override
  Widget build(BuildContext context) {
    if (divesite.position == null) {
      return Card(
        elevation: 2,
        child: Container(height: height, alignment: Alignment.center, child: const Text('No location data available')),
      );
    }

    final position = LatLng(divesite.position!.lat, divesite.position!.lon);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(initialCenter: position, initialZoom: 15.0, minZoom: 3.0, maxZoom: 18.0),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'net.kastelo.osdl', maxZoom: 19),
            MarkerLayer(
              markers: [
                Marker(
                  point: position,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_pin, size: 40, color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
