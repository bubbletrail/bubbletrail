import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_metadata.dart';

class SiteMap extends StatelessWidget {
  final LatLng? sitePosition;
  final void Function(TapPosition, LatLng)? onTap;
  final bool alwaysCenterPosition;
  final LatLng? startPosition;
  final LatLng? endPosition;

  const SiteMap({super.key, this.sitePosition, this.startPosition, this.endPosition, this.onTap, this.alwaysCenterPosition = true});

  @override
  Widget build(BuildContext context) {
    final markers = [
      if (sitePosition != null)
        Marker(
          point: sitePosition!,
          width: 32,
          height: 32,
          alignment: Alignment.topCenter, // point is at bottom center
          child: Icon(Icons.location_on, size: 28, color: Colors.redAccent),
        ),
      if (startPosition != null)
        Marker(
          point: startPosition!,
          width: 32,
          height: 32,
          alignment: Alignment.topCenter, // point is at bottom center
          child: Icon(Icons.arrow_drop_down, size: 28, color: Colors.blueAccent),
        ),
      if (endPosition != null)
        Marker(
          point: endPosition!,
          width: 32,
          height: 32,
          alignment: Alignment.topCenter, // point is at bottom center
          child: Icon(Icons.arrow_drop_up, size: 28, color: Colors.blueAccent),
        ),
    ];
    return _SiteMap(key: key, markers: markers, onTap: onTap, alwaysCenterPosition: alwaysCenterPosition);
  }
}

class AllSitesMap extends StatelessWidget {
  final List<Site> sites;
  final void Function(TapPosition, LatLng)? onTap;

  const AllSitesMap({super.key, required this.sites, this.onTap});

  @override
  Widget build(BuildContext context) {
    final markers = sites
        .where((s) => s.hasPosition())
        .map(
          (s) => Marker(
            point: LatLng(s.position.latitude, s.position.longitude),
            width: 32,
            height: 32,
            alignment: Alignment.topCenter, // point is at bottom center
            child: Tooltip(
              triggerMode: .tap,
              message: '${s.name},\n${s.location}, ${s.country}',
              showDuration: Duration(seconds: 5),
              child: Icon(Icons.location_on, size: 28, color: Colors.redAccent),
            ),
          ),
        )
        .toList();
    return _SiteMap(key: key, markers: markers, onTap: onTap, alwaysCenterPosition: false, initialZoom: 2.0);
  }
}

class _SiteMap extends StatefulWidget {
  final List<Marker> markers;
  final void Function(TapPosition, LatLng)? onTap;
  final bool alwaysCenterPosition;
  final double initialZoom;

  LatLng get centerPos {
    if (markers.isEmpty) return LatLng(0, 0);
    double tlat = 0, tlon = 0, n = 0;
    for (final m in markers) {
      tlat += m.point.latitude;
      tlon += m.point.longitude;
      n++;
    }
    return LatLng(tlat / n, tlon / n);
  }

  const _SiteMap({super.key, required this.markers, this.onTap, this.alwaysCenterPosition = true, this.initialZoom = 13.0});

  @override
  State<_SiteMap> createState() => _SiteMapState();
}

class _SiteMapState extends State<_SiteMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(_SiteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alwaysCenterPosition && oldWidget.centerPos != widget.centerPos) {
      _mapController.move(widget.centerPos, _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiles = azureMapsSubscriptionKey.isNotEmpty
        ? [
            // Azure layers
            TileLayer(
              urlTemplate:
                  'https://atlas.microsoft.com/map/tile?api-version=2022-08-01&tilesetId={tilesetId}&zoom={z}&x={x}&y={y}&tileSize={tileSize}&subscription-key={subscriptionKey}',
              additionalOptions: {'tilesetId': 'microsoft.imagery', 'tileSize': '512', 'subscriptionKey': azureMapsSubscriptionKey},
            ),
            TileLayer(
              urlTemplate:
                  'https://atlas.microsoft.com/map/tile?api-version=2022-08-01&tilesetId={tilesetId}&zoom={z}&x={x}&y={y}&tileSize={tileSize}&subscription-key={subscriptionKey}',
              additionalOptions: {'tilesetId': 'microsoft.base.hybrid.road', 'tileSize': '512', 'subscriptionKey': azureMapsSubscriptionKey},
            ),
          ]
        : [
            // OSM layer
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'app.bubbletrail.bubbletrail', maxZoom: 19),
          ];

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: widget.centerPos, initialZoom: widget.initialZoom, minZoom: 3.0, maxZoom: 18.0, onTap: widget.onTap),
      children: [
        ...tiles,
        MarkerLayer(markers: widget.markers),
      ],
    );
  }
}
