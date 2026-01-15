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
          child: Wrap(
            alignment: .start,
            crossAxisAlignment: .start,
            spacing: 8,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: .start,
                spacing: 8,
                children: [
                  SiteMapWidget(site: site, showFullscreenButton: true),
                  TagsList(tags: site.tags, prefix: '#'),
                ],
              ),
              Card(
                child: Padding(
                  padding: const .all(16.0),
                  child: DataCardColumn(
                    children: [
                      if (site.country.isNotEmpty) ColumnRow(label: 'Country', child: Text(site.country)),
                      if (site.location.isNotEmpty) ColumnRow(label: 'Location', child: Text(site.location)),
                      if (site.bodyOfWater.isNotEmpty) ColumnRow(label: 'Body of Water', child: Text(site.bodyOfWater)),
                      if (site.hasPosition())
                        ColumnRow(label: 'Position', child: Text([formatLatitude(site.position.latitude), formatLongitude(site.position.longitude)].join(' '))),
                      if (site.difficulty.isNotEmpty) ColumnRow(label: 'Difficulty', child: Text(site.difficulty)),
                    ],
                  ),
                ),
              ),
              if (site.notes.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const .all(8.0),
                    child: Text(site.notes, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              ],
              if (dives.isNotEmpty)
                AspectRatio(
                  aspectRatio: 2,
                  child: DiveTableWidget(dives: dives, sitesByUuid: state.sitesByUuid, showSiteColumn: false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
