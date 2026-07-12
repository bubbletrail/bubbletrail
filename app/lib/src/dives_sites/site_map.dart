import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_metadata.dart';

class SiteMap extends StatefulWidget {
  final LatLng? sitePosition;
  final void Function(TapPosition, LatLng)? onTap;
  final bool alwaysCenterPosition;
  final LatLng? startPosition;
  final LatLng? endPosition;

  LatLng get centerPos {
    if (sitePosition == null && startPosition == null && endPosition == null) return LatLng(0, 0);
    double tlat = 0, tlon = 0, n = 0;
    if (sitePosition != null) {
      tlat += sitePosition!.latitude;
      tlon += sitePosition!.longitude;
      n += 1;
    }
    if (startPosition != null) {
      tlat += startPosition!.latitude;
      tlon += startPosition!.longitude;
      n += 1;
    }
    if (endPosition != null) {
      tlat += endPosition!.latitude;
      tlon += endPosition!.longitude;
      n += 1;
    }
    return LatLng(tlat / n, tlon / n);
  }

  const SiteMap({super.key, this.sitePosition, this.startPosition, this.endPosition, this.onTap, this.alwaysCenterPosition = true});

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
            if (widget.startPosition != null)
              Marker(
                point: widget.startPosition!,
                width: 32,
                height: 32,
                alignment: Alignment.topCenter, // point is at bottom center
                child: Icon(Icons.arrow_drop_down, size: 28, color: Colors.blueAccent),
              ),
            if (widget.endPosition != null)
              Marker(
                point: widget.endPosition!,
                width: 32,
                height: 32,
                alignment: Alignment.topCenter, // point is at bottom center
                child: Icon(Icons.arrow_drop_up, size: 28, color: Colors.blueAccent),
              ),
          ],
        ),
      ],
    );
  }
}
