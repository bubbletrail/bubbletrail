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

class DiveSiteListScreen extends StatelessWidget {
  const DiveSiteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Dive Sites'),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: 'Add new dive site', onPressed: () => context.pushNamed(AppRouteName.sitesNew))],
      body: BlocBuilder<DiveListBloc, DiveListState>(
        builder: (context, state) {
          if (state is DiveListInitial || state is DiveListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiveListError) {
            return ErrorStateWidget(title: 'Error loading dive sites', message: state.message);
          }

          if (state is DiveListLoaded) {
            final diveSites = state.diveSites;

            if (diveSites.isEmpty) {
              return const EmptyStateWidget(message: 'No dive sites yet.', icon: Icons.location_on);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < _narrowLayoutBreakpoint;
                return isNarrow ? _buildCardList(context, diveSites, state.diveCountBySiteId) : _buildTrinaGrid(context, diveSites, state.diveCountBySiteId);
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<Divesite> diveSites, Map<String, int> diveCountBySiteId) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: diveSites.length,
      itemBuilder: (context, index) {
        final site = diveSites[index];
        final diveCount = diveCountBySiteId[site.uuid] ?? 0;
        return DiveSiteListItemCard(site: site, diveCount: diveCount);
      },
    );
  }

  Widget _buildTrinaGrid(BuildContext context, List<Divesite> diveSites, Map<String, int> diveCountBySiteId) {
    final columns = <TrinaColumn>[
      TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text(), width: 200, readOnly: true),
      TrinaColumn(title: 'Country', field: 'country', type: TrinaColumnType.text(), width: 120, readOnly: true),
      TrinaColumn(title: 'Location', field: 'location', type: TrinaColumnType.text(), width: 150, readOnly: true),
      TrinaColumn(title: 'Body of Water', field: 'bodyOfWater', type: TrinaColumnType.text(), width: 150, readOnly: true),
      TrinaColumn(title: 'Difficulty', field: 'difficulty', type: TrinaColumnType.text(), width: 100, readOnly: true),
      TrinaColumn(title: '# Dives', field: 'diveCount', type: TrinaColumnType.number(), width: 80, readOnly: true),
    ];

    final rows = diveSites.map((site) {
      final diveCount = diveCountBySiteId[site.uuid] ?? 0;
      return TrinaRow(
        cells: {
          'name': TrinaCell(value: site.name),
          'country': TrinaCell(value: site.country ?? '-'),
          'location': TrinaCell(value: site.location ?? '-'),
          'bodyOfWater': TrinaCell(value: site.bodyOfWater ?? '-'),
          'difficulty': TrinaCell(value: site.difficulty ?? '-'),
          'diveCount': TrinaCell(value: diveCount),
          '_uuid': TrinaCell(value: site.uuid), // Hidden field for navigation
        },
      );
    }).toList();

    return TrinaGrid(
      columns: columns,
      rows: rows,
      mode: TrinaGridMode.selectWithOneTap,
      onRowDoubleTap: (event) {
        final siteId = event.row.cells['_uuid']?.value as String?;
        if (siteId != null) {
          context.pushNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': siteId});
        }
      },
      configuration: AppTheme.trinaGridConfiguration(context),
    );
  }
}
