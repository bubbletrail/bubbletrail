import 'package:divepath/src/ssrf/ssrf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Widget buildInfoCard(BuildContext context, String title, List<Widget> children) {
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

Widget buildInfoRow(String label, String value) {
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
