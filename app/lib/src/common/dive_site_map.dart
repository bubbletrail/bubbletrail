import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../ssrf/ssrf.dart' as ssrf;

class DiveSiteMap extends StatefulWidget {
  const DiveSiteMap({super.key, required this.position});

  final ssrf.GPSPosition position;

  @override
  State<DiveSiteMap> createState() => _DiveSiteMapState();
}

class _DiveSiteMapState extends State<DiveSiteMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(DiveSiteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position.lat != widget.position.lat || oldWidget.position.lon != widget.position.lon) {
      _mapController.move(LatLng(widget.position.lat, widget.position.lon), _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latlng = LatLng(widget.position.lat, widget.position.lon);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: latlng, initialZoom: 15.0, minZoom: 3.0, maxZoom: 18.0),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'app.bubbletrail.bubbletrail', maxZoom: 19),
        MarkerLayer(
          markers: [
            Marker(
              point: latlng,
              width: 40,
              height: 40,
              child: Icon(Icons.location_pin, size: 40, color: Colors.redAccent),
            ),
          ],
        ),
      ],
    );
  }
}
