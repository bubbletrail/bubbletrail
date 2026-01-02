import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_metadata.dart';

class SiteMap extends StatefulWidget {
  final LatLng position;
  final void Function(TapPosition, LatLng)? onTap;
  final bool alwaysCenterPosition;

  const SiteMap({super.key, required this.position, this.onTap, this.alwaysCenterPosition = true});

  @override
  State<SiteMap> createState() => _SiteMapState();
}

class _SiteMapState extends State<SiteMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(SiteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alwaysCenterPosition && oldWidget.position != widget.position) {
      _mapController.move(LatLng(widget.position.latitude, widget.position.longitude), _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: widget.position, initialZoom: 15.0, minZoom: 3.0, maxZoom: 18.0, onTap: widget.onTap),
      children: [
        // We use Azure layers if we have a key
        if (azureMapsSubscriptionKey.isNotEmpty)
          TileLayer(
            urlTemplate:
                'https://atlas.microsoft.com/map/tile?api-version=2022-08-01&tilesetId={tilesetId}&zoom={z}&x={x}&y={y}&tileSize={tileSize}&subscription-key={subscriptionKey}',
            additionalOptions: {'tilesetId': 'microsoft.imagery', 'tileSize': '512', 'subscriptionKey': azureMapsSubscriptionKey},
          ),
        if (azureMapsSubscriptionKey.isNotEmpty)
          TileLayer(
            urlTemplate:
                'https://atlas.microsoft.com/map/tile?api-version=2022-08-01&tilesetId={tilesetId}&zoom={z}&x={x}&y={y}&tileSize={tileSize}&subscription-key={subscriptionKey}',
            additionalOptions: {'tilesetId': 'microsoft.base.hybrid.road', 'tileSize': '512', 'subscriptionKey': azureMapsSubscriptionKey},
          ),
        // Otherwise we use an OpenStreetMap layer
        if (azureMapsSubscriptionKey.isEmpty)
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'app.bubbletrail.bubbletrail', maxZoom: 19),
        MarkerLayer(
          markers: [
            Marker(
              point: widget.position,
              width: 32,
              height: 32,
              alignment: Alignment.topCenter, // point is at bottom center
              child: Icon(Icons.location_pin, size: 32, color: Colors.redAccent),
            ),
          ],
        ),
      ],
    );
  }
}
