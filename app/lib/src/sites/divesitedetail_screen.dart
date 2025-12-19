import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
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

    final site = state.diveSitesByUuid[siteID]!;
    final dives = state.dives.where((s) => s.divesiteid == siteID).toList();

    return ScreenScaffold(
      title: Text(site.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () => context.pushNamed(AppRouteName.sitesDetailsEdit, pathParameters: {'siteID': siteID}),
        ),
      ],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoCard(context, 'Location Information', [
                infoRow('Name', site.name),
                if (site.country != null) infoRow('Country', site.country!),
                if (site.location != null) infoRow('Location', site.location!),
                if (site.bodyOfWater != null) infoRow('Body of Water', site.bodyOfWater!),
                if (site.position != null) ...[
                  infoRow('Latitude', site.position!.lat.toStringAsFixed(6)),
                  infoRow('Longitude', site.position!.lon.toStringAsFixed(6)),
                ],
              ]),
              if (site.difficulty != null) ...[
                const SizedBox(height: 16),
                infoCard(context, 'Dive Information', [infoRow('Difficulty', site.difficulty!)]),
              ],
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
                        AspectRatio(
                          aspectRatio: 2,
                          child: DiveTableWidget(dives: dives, diveSitesByUuid: state.diveSitesByUuid, showSiteColumn: false),
                        ),
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
