import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';

class DiveSiteMapWidget extends StatelessWidget {
  final Divesite divesite;
  final double height;

  const DiveSiteMapWidget({super.key, required this.divesite, this.height = 300});

  @override
  Widget build(BuildContext context) {
    if (divesite.position == null) {
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
        child: DiveSiteMap(position: divesite.position!),
      ),
    );
  }
}
