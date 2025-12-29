import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trina_grid/trina_grid.dart';

import '../app_routes.dart';
import '../app_theme.dart';
import '../bloc/preferences_bloc.dart';
import 'common.dart';

/// Breakpoint width for switching between card (narrow) and table (wide) layouts.
const double _narrowLayoutBreakpoint = 600;

class DiveTableWidget extends StatelessWidget {
  final List<Dive> dives;
  final Map<String, Site> sitesByUuid;
  final bool showSiteColumn;

  const DiveTableWidget({super.key, required this.dives, required this.sitesByUuid, this.showSiteColumn = true});

  Site? _getSite(Dive dive) {
    if (dive.siteId.isEmpty) return null;
    return sitesByUuid[dive.siteId];
  }

  @override
  Widget build(BuildContext context) {
    if (dives.isEmpty) {
      return const Center(child: Text('No dives to display'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < _narrowLayoutBreakpoint;
        return isNarrow ? _buildCardList(context) : _buildTrinaGrid(context);
      },
    );
  }

  Widget _buildCardList(BuildContext context) {
    // Sort by date descending for card list
    final sortedDives = List<Dive>.from(dives)..sort((a, b) => b.start.toDateTime().compareTo(a.start.toDateTime()));
    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sortedDives.length,
          itemBuilder: (context, index) {
            final dive = sortedDives[index];
            return DiveListItemCard(dive: dive, site: _getSite(dive), showSite: showSiteColumn);
          },
        );
      },
    );
  }

  Widget _buildTrinaGrid(BuildContext context) {
    final columns = <TrinaColumn>[
      TrinaColumn(title: 'Dive #', field: 'number', type: TrinaColumnType.number(), width: 80, readOnly: true, sort: TrinaColumnSort.descending),
      TrinaColumn(title: 'Start', field: 'start', type: TrinaColumnType.dateTime(), width: 120, readOnly: true),
      TrinaColumn(title: 'Max Depth', field: 'maxDepth', type: TrinaColumnType.number(), width: 80, readOnly: true),
      TrinaColumn(title: 'Duration', field: 'duration', type: TrinaColumnType.number(), width: 80, readOnly: true),
      if (showSiteColumn) TrinaColumn(title: 'Site', field: 'site', type: TrinaColumnType.text(), width: 200, readOnly: true),
    ];

    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, state) {
        final rows = dives.map((dive) {
          final site = _getSite(dive);
          return TrinaRow(
            cells: {
              'number': TrinaCell(value: dive.number),
              'start': TrinaCell(value: dive.start.toDateTime()),
              'maxDepth': TrinaCell(value: convertDepth(context, dive.maxDepth)),
              'duration': TrinaCell(value: dive.duration, renderer: (rendererContext) => Text(formatDuration(rendererContext.cell.value))),
              'site': TrinaCell(value: site?.name ?? ''),
              '_id': TrinaCell(value: dive.id), // Hidden field for navigation
            },
          );
        }).toList();
        return TrinaGrid(
          key: ValueKey(state.preferences), // ensure recreation when preferences change... do we need to be more specific?
          columns: columns,
          rows: rows,
          mode: TrinaGridMode.selectWithOneTap,
          onRowDoubleTap: (event) {
            final diveId = event.row.cells['_id']?.value as String?;
            if (diveId != null) {
              context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': diveId});
            }
          },
          configuration: AppTheme.trinaGridConfiguration(context),
        );
      },
    );
  }
}
