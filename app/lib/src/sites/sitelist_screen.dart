import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trina_grid/trina_grid.dart';

import '../app_routes.dart';
import '../app_theme.dart';
import '../bloc/divelist_bloc.dart';
import '../common/common.dart';

/// Breakpoint width for switching between card (narrow) and table (wide) layouts.
const double _narrowLayoutBreakpoint = 600;

class SiteListScreen extends StatelessWidget {
  const SiteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Dive Sites'),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: 'Add new dive site', onPressed: () => context.goNamed(AppRouteName.sitesNew))],
      body: BlocBuilder<DiveListBloc, DiveListState>(
        builder: (context, state) {
          if (state is DiveListInitial || state is DiveListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiveListLoaded) {
            final sites = state.sites;

            if (sites.isEmpty) {
              return const EmptyStateWidget(message: 'No dive sites yet.', icon: Icons.location_on);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < _narrowLayoutBreakpoint;
                return isNarrow ? _buildCardList(context, sites, state.diveCountBySiteId) : _buildTrinaGrid(context, sites, state.diveCountBySiteId);
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<Site> sites, Map<String, int> diveCountBySiteId) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final site = sites[index];
        final diveCount = diveCountBySiteId[site.id] ?? 0;
        return SiteListItemCard(site: site, diveCount: diveCount);
      },
    );
  }

  Widget _buildTrinaGrid(BuildContext context, List<Site> sites, Map<String, int> diveCountBySiteId) {
    final columns = <TrinaColumn>[
      TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text(), width: 200, readOnly: true),
      TrinaColumn(title: 'Country', field: 'country', type: TrinaColumnType.text(), width: 120, readOnly: true),
      TrinaColumn(title: 'Location', field: 'location', type: TrinaColumnType.text(), width: 150, readOnly: true),
      TrinaColumn(title: 'Body of Water', field: 'bodyOfWater', type: TrinaColumnType.text(), width: 150, readOnly: true),
      TrinaColumn(title: 'Difficulty', field: 'difficulty', type: TrinaColumnType.text(), width: 100, readOnly: true),
      TrinaColumn(title: '# Dives', field: 'diveCount', type: TrinaColumnType.number(), width: 80, readOnly: true),
    ];

    final rows = sites.map((site) {
      final diveCount = diveCountBySiteId[site.id] ?? 0;
      return TrinaRow(
        cells: {
          'name': TrinaCell(value: site.name),
          'country': TrinaCell(value: site.country.isEmpty ? '-' : site.country),
          'location': TrinaCell(value: site.location.isEmpty ? '-' : site.location),
          'bodyOfWater': TrinaCell(value: site.bodyOfWater.isEmpty ? '-' : site.bodyOfWater),
          'difficulty': TrinaCell(value: site.difficulty.isEmpty ? '-' : site.difficulty),
          'diveCount': TrinaCell(value: diveCount),
          '_uuid': TrinaCell(value: site.id), // Hidden field for navigation
        },
      );
    }).toList();

    return TrinaGrid(
      key: ValueKey(sites),
      columns: columns,
      rows: rows,
      mode: TrinaGridMode.selectWithOneTap,
      onRowDoubleTap: (event) {
        final siteId = event.row.cells['_uuid']?.value as String?;
        if (siteId != null) {
          context.goNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': siteId});
        }
      },
      configuration: AppTheme.trinaGridConfiguration(context),
    );
  }
}
