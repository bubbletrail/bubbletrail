import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import 'dive_list_bloc.dart';
import '../common/common.dart';
import 'site_map.dart';

class FullscreenMapScreen extends StatelessWidget {
  const FullscreenMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cs.tertiaryContainer, cs.onTertiaryFixedVariant],
        tileMode: .mirror,
      ),
    );

    return Container(
      decoration: decoration,
      child: BlocBuilder<DiveListBloc, DiveListState>(
        builder: (context, state) {
          if (state is! DiveListLoaded) return const Placeholder();
          final site = state.selectedSite!;

          if (!site.hasPosition()) {
            return ScreenScaffold(
              title: Text(site.name),
              body: const Center(child: Text('No location data available')),
            );
          }

          return ScreenScaffold(
            title: Text(site.name),
            body: SiteMap(position: LatLng(site.position.latitude, site.position.longitude)),
          );
        },
      ),
    );
  }
}
