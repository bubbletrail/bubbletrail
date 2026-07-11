import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_metadata.dart';

class SiteMap extends StatefulWidget {
  final LatLng? sitePosition;
  final void Function(TapPosition, LatLng)? onTap;
  final bool alwaysCenterPosition;
  final LatLng? divePosition;

  LatLng get centerPos {
    if (sitePosition == null && divePosition == null) return LatLng(0, 0);
    if (sitePosition == null && divePosition != null) return divePosition!;
    if (sitePosition != null && divePosition == null) return sitePosition!;
    return LatLng((sitePosition!.latitude + divePosition!.latitude) / 2, (sitePosition!.longitude + divePosition!.longitude) / 2);
  }

  const SiteMap({super.key, this.sitePosition, this.onTap, this.alwaysCenterPosition = true, this.divePosition});

  @override
  State<SiteMap> createState() => _SiteMapState();
}

class _SiteMapState extends State<SiteMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(SiteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alwaysCenterPosition && oldWidget.centerPos != widget.centerPos) {
      _mapController.move(widget.centerPos, _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: widget.centerPos, initialZoom: 15.0, minZoom: 3.0, maxZoom: 18.0, onTap: widget.onTap),
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
            if (widget.sitePosition != null)
              Marker(
                point: widget.sitePosition!,
                width: 32,
                height: 32,
                alignment: Alignment.topCenter, // point is at bottom center
                child: Icon(Icons.location_on, size: 28, color: Colors.redAccent),
              ),
            if (widget.divePosition != null)
              Marker(
                point: widget.divePosition!,
                width: 32,
                height: 32,
                alignment: Alignment.topCenter, // point is at bottom center
                child: Icon(Icons.scuba_diving, size: 28, color: Colors.blueAccent),
              ),
          ],
        ),
      ],
    );
  }
}
