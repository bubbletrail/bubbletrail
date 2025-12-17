import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/divelist_bloc.dart';
import '../common/common.dart';
import 'divesitemap_widget.dart';

class DiveSiteDetailScreen extends StatelessWidget {
  final String siteID;

  const DiveSiteDetailScreen({super.key, required this.siteID});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DiveListBloc>().state;
    if (state is! DiveListLoaded) {
      return Placeholder();
    }

    final site = state.diveSites.firstWhere((s) => s.uuid == siteID);
    final dives = state.dives.where((s) => s.divesiteid == siteID).toList();

    return ScreenScaffold(
      title: Text(site.name),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoCard(context, 'Location Information', [
                infoRow('Name', site.name),
                if (site.position != null) ...[
                  infoRow('Latitude', site.position!.lat.toStringAsFixed(6)),
                  infoRow('Longitude', site.position!.lon.toStringAsFixed(6)),
                ],
              ]),
              const SizedBox(height: 16),
              DiveSiteMapWidget(divesite: site),
              const SizedBox(height: 16),
              if (dives.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dives at this site (${dives.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const Divider(),
                        DiveTableWidget(dives: dives, diveSites: state.diveSites, showSiteColumn: false),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No dives recorded at this site', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
