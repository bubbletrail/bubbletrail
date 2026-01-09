import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../app_routes.dart';
import '../common/common.dart';

class SiteMapWidget extends StatelessWidget {
  final Site site;
  final double height;
  final bool showFullscreenButton;

  const SiteMapWidget({super.key, required this.site, this.height = 300, this.showFullscreenButton = false});

  @override
  Widget build(BuildContext context) {
    if (!site.hasPosition()) {
      return Card(
        elevation: 2,
        child: Container(height: height, alignment: .center, child: const Text('No location data available')),
      );
    }

    return Card(
      elevation: 2,
      clipBehavior: .antiAlias,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            IgnorePointer(child: SiteMap(position: LatLng(site.position.latitude, site.position.longitude))),
            if (showFullscreenButton)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  icon: const FaIcon(FontAwesomeIcons.expand),
                  onPressed: () {
                    context.pushNamed(AppRouteName.sitesDetailsMap, pathParameters: {'siteID': site.id});
                  },
                  tooltip: 'View fullscreen',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
