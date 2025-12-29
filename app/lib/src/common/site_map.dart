import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SiteMap extends StatefulWidget {
  const SiteMap({super.key, required this.position});

  final Position position;

  @override
  State<SiteMap> createState() => _SiteMapState();
}

class _SiteMapState extends State<SiteMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(SiteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position.latitude != widget.position.latitude || oldWidget.position.longitude != widget.position.longitude) {
      _mapController.move(LatLng(widget.position.latitude, widget.position.longitude), _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latlng = LatLng(widget.position.latitude, widget.position.longitude);
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
