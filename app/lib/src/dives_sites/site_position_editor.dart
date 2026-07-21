import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../common/common.dart';
import 'site_map.dart';

// Shows an editor for a site's GPS position. On mobile this is a bottom sheet,
// on desktop a modal dialog. The position can be set by tapping the map or
// entering coordinates, and cleared entirely. Returns a SelectionResult:
// cancelled (no change), none (position cleared) or selected (new position).
Future<SelectionResult<Position>> showSitePositionEditor({required BuildContext context, Position? position}) async {
  final result = await showAdaptiveModal<SelectionResult<Position>>(
    context: context,
    builder: (context) => _SitePositionEditor(position: position),
  );
  return result ?? const SelectionResult<Position>.cancelled();
}

class _SitePositionEditor extends StatefulWidget {
  final Position? position;

  const _SitePositionEditor({required this.position});

  @override
  State<_SitePositionEditor> createState() => _SitePositionEditorState();
}

class _SitePositionEditorState extends State<_SitePositionEditor> {
  late final TextEditingController _latController;
  late final TextEditingController _lonController;
  LatLng? _markerPosition;
  String? _error;

  @override
  void initState() {
    super.initState();
    final pos = widget.position;
    _latController = TextEditingController(text: pos != null ? pos.latitude.toString() : '');
    _lonController = TextEditingController(text: pos != null ? pos.longitude.toString() : '');
    if (pos != null) _markerPosition = LatLng(pos.latitude, pos.longitude);
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _markerPosition = point;
      _latController.text = point.latitude.toStringAsFixed(6);
      _lonController.text = point.longitude.toStringAsFixed(6);
      _error = null;
    });
  }

  // Keep the map marker in sync with manually entered coordinates.
  void _onCoordsChanged() {
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());
    if (lat != null && lon != null) {
      setState(() {
        _markerPosition = LatLng(lat, lon);
        _error = null;
      });
    }
  }

  void _done() {
    final latText = _latController.text.trim();
    final lonText = _lonController.text.trim();
    if (latText.isEmpty && lonText.isEmpty) {
      Navigator.of(context).pop(const SelectionResult<Position>.none());
      return;
    }
    final lat = double.tryParse(latText);
    final lon = double.tryParse(lonText);
    if (lat == null || lon == null) {
      setState(() => _error = 'Enter valid coordinates, or clear both fields.');
      return;
    }
    Navigator.of(context).pop(SelectionResult<Position>.selected(Position(latitude: lat, longitude: lon)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const .all(16.0),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 16,
          children: [
            Text('Position', style: Theme.of(context).textTheme.titleMedium),
            AspectRatio(
              aspectRatio: 2,
              child: ClipRRect(
                borderRadius: .circular(12),
                child: SiteMap(sitePosition: _markerPosition ?? const LatLng(0, 0), onTap: _onMapTap, alwaysCenterPosition: false),
              ),
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                    keyboardType: const .numberWithOptions(decimal: true, signed: true),
                    onChanged: (_) => _onCoordsChanged(),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _lonController,
                    decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                    keyboardType: const .numberWithOptions(decimal: true, signed: true),
                    onChanged: (_) => _onCoordsChanged(),
                  ),
                ),
              ],
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(onPressed: _done, child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
