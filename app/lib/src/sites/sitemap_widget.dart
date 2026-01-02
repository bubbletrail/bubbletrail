import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../common/common.dart';

class SiteMapWidget extends StatelessWidget {
  final Site site;
  final double height;

  const SiteMapWidget({super.key, required this.site, this.height = 300});

  @override
  Widget build(BuildContext context) {
    if (!site.hasPosition()) {
      return Card(
        elevation: 2,
        child: Container(height: height, alignment: Alignment.center, child: const Text('No location data available')),
      );
    }

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: SiteMap(position: LatLng(site.position.latitude, site.position.longitude)),
      ),
    );
  }
}
