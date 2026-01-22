import 'package:btstore/btstore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import 'dive_list_bloc.dart';
import '../common/common.dart';
import 'dive_table.dart';
import 'site_details_bloc.dart';
import 'site_map_card.dart';

class SiteDetailsScreen extends StatelessWidget {
  const SiteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final siteDetailState = context.read<SiteDetailsBloc>().state;
    if (siteDetailState is! SiteDetailsLoaded) {
      // Can't happen
      return Placeholder();
    }

    final diveListState = context.read<DiveListBloc>().state;
    if (diveListState is! DiveListLoaded) {
      // Can't happen
      return Placeholder();
    }

    final site = siteDetailState.site;
    final dives = diveListState.dives.where((s) => s.siteId == site.id).toList();

    return BlocListener<SiteDetailsBloc, SiteDetailsState>(
      listener: (context, state) {
        if (state is SiteDetailsClosed) {
          // Pop when the bloc considers us done
          context.pop();
        }
      },
      child: ScreenScaffold(
        title: Text(site.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => context.goNamed(AppRouteName.sitesDetailsEdit, pathParameters: {'siteID': site.id}),
          ),
          _popupMenuActions(context, site),
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
                    SiteMapCard(site: site, showFullscreenButton: true),
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
                          ColumnRow(
                            label: 'Position',
                            child: Text([formatLatitude(site.position.latitude), formatLongitude(site.position.longitude)].join(' ')),
                          ),
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
                    child: DiveTable(dives: dives, sitesByUuid: diveListState.sitesByUuid, showSiteColumn: false),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuButton<String> _popupMenuActions(BuildContext context, Site site) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'delete') {
          final confirmed = await showConfirmationDialog(
            context: context,
            title: 'Delete site',
            message: 'Are you sure you want to delete the site ${site.name}? Dives using this site will be left without site. This cannot be undone.',
            confirmText: 'Delete',
            isDestructive: true,
          );
          if (confirmed && context.mounted) {
            context.read<SiteDetailsBloc>().add(SiteDetailsEvent.deleteAndClose(site.id));
          }
        }
      },
      itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Text('Delete site'))],
    );
  }
}
