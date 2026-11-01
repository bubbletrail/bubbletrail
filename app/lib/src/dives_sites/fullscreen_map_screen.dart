import 'package:btl10n/btl10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../common/common.dart';
import 'site_details_bloc.dart';
import 'site_map.dart';

class FullscreenMapScreen extends StatelessWidget {
  final LatLng? startPosition;
  final LatLng? endPosition;

  const FullscreenMapScreen({super.key, this.startPosition, this.endPosition});

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
      child: BlocBuilder<SiteDetailsBloc, SiteDetailsState>(
        builder: (context, state) {
          if (state is! SiteDetailsLoaded) return const Placeholder();

          if (!state.site.hasPosition()) {
            return ScreenScaffold(
              title: Text(state.site.name),
              body: Center(child: Text(context.l10n.noLocationDataAvailable)),
            );
          }

          return ScreenScaffold(
            title: Text(state.site.name),
            body: SiteMap(
              sitePosition: LatLng(state.site.position.latitude, state.site.position.longitude),
              startPosition: startPosition,
              endPosition: endPosition,
            ),
          );
        },
      ),
    );
  }
}
