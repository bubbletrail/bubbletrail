import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../ssrf/ssrf.dart';

class DiveSiteMap extends StatelessWidget {
  const DiveSiteMap({super.key, required this.position});

  final GPSPosition position;

  @override
  Widget build(BuildContext context) {
    final latlng = LatLng(position.lat, position.lon);
    return FlutterMap(
      options: MapOptions(initialCenter: latlng, initialZoom: 15.0, minZoom: 3.0, maxZoom: 18.0),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'org.divepath.divepath', maxZoom: 19),
        MarkerLayer(
          markers: [
            Marker(
              point: latlng,
              width: 40,
              height: 40,
              child: Icon(Icons.location_pin, size: 40, color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ],
    );
  }
}
