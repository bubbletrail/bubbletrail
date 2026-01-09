import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../bloc/divelist_bloc.dart';
import '../common/common.dart';
import 'sitemap_widget.dart';

class SiteDetailScreen extends StatelessWidget {
  const SiteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DiveListBloc>().state;
    if (state is! DiveListLoaded) {
      return Placeholder();
    }

    final site = state.selectedSite!;
    final dives = state.dives.where((s) => s.siteId == site.id).toList();

    return ScreenScaffold(
      title: Text(site.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () => context.goNamed(AppRouteName.sitesDetailsEdit, pathParameters: {'siteID': site.id}),
        ),
      ],
      body: SingleChildScrollView(
        child: Padding(
          padding: const .all(8.0),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              infoCard(context, 'Location Information', [
                infoRow('Name', site.name),
                if (site.country.isNotEmpty) infoRow('Country', site.country),
                if (site.location.isNotEmpty) infoRow('Location', site.location),
                if (site.bodyOfWater.isNotEmpty) infoRow('Body of Water', site.bodyOfWater),
                if (site.hasPosition()) infoRow('Position', [formatLatitude(site.position.latitude), formatLongitude(site.position.longitude)].join(' ')),
              ]),
              if (site.difficulty.isNotEmpty || site.tags.isNotEmpty) ...[
                infoCard(context, 'Dive Information', [
                  if (site.difficulty.isNotEmpty) infoRow('Difficulty', site.difficulty),
                  if (site.tags.isNotEmpty) tagsRow(context, site.tags.toList()),
                ]),
              ],
              if (site.notes.isNotEmpty) ...[
                infoCard(context, 'Notes', [
                  Padding(
                    padding: const .only(top: 8.0),
                    child: Text(site.notes, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ]),
              ],
              SiteMapWidget(site: site, showFullscreenButton: true),
              if (dives.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16.0),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text('Dives at this site (${dives.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: .bold)),
                        const Divider(),
                        AspectRatio(
                          aspectRatio: 2,
                          child: DiveTableWidget(dives: dives, sitesByUuid: state.sitesByUuid, showSiteColumn: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16.0),
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
