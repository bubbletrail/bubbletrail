import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trina_grid/trina_grid.dart';

import '../app_routes.dart';
import '../app_theme.dart';
import '../common/common.dart';
import '../preferences/preferences_bloc.dart';
import 'dive_list_item_card.dart';

/// Breakpoint width for switching between card (narrow) and table (wide) layouts.
const double _narrowLayoutBreakpoint = 600;

class DiveTable extends StatelessWidget {
  final List<Dive> dives;
  final Map<String, Site> sitesByUuid;
  final bool showSiteColumn;

  const DiveTable({super.key, required this.dives, required this.sitesByUuid, this.showSiteColumn = true});

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
          padding: const .symmetric(vertical: 8),
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
    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, state) {
        final columns = <TrinaColumn>[
          TrinaColumn(title: 'Dive #', field: 'number', type: .number(), width: 80, readOnly: true, sort: .descending),
          TrinaColumn(
            title: 'Start',
            field: 'start',
            type: .dateTime(format: state.preferences.dateTimeFormat),
            width: 120,
            readOnly: true,
          ),
          TrinaColumn(title: 'Max depth', field: 'maxDepth', type: .number(), width: 80, readOnly: true),
          TrinaColumn(title: 'Duration', field: 'duration', type: .number(), width: 80, readOnly: true),
          if (showSiteColumn) TrinaColumn(title: 'Country', field: 'country', type: .text(), width: 120, readOnly: true),
          if (showSiteColumn) TrinaColumn(title: 'Location', field: 'location', type: .text(), width: 120, readOnly: true),
          if (showSiteColumn) TrinaColumn(title: 'Site', field: 'site', type: .text(), width: 120, readOnly: true),
          TrinaColumn(title: 'SAC', field: 'sac', type: .number(), width: 80, readOnly: true),
        ];
        final rows = dives.map((dive) {
          final site = _getSite(dive);
          return TrinaRow(
            cells: {
              'number': TrinaCell(value: dive.number),
              'start': TrinaCell(value: dive.start.toDateTime()),
              'maxDepth': TrinaCell(value: dive.maxDepth * 10, renderer: (rendererContext) => DepthText(rendererContext.cell.value / 10)),
              'duration': TrinaCell(value: dive.duration, renderer: (rendererContext) => DurationText(rendererContext.cell.value)),
              'country': TrinaCell(value: site?.country ?? ''),
              'location': TrinaCell(value: site?.location ?? ''),
              'site': TrinaCell(value: site?.name ?? ''),
              'sac': TrinaCell(
                value: dive.sac * 10,
                renderer: (rendererContext) => rendererContext.cell.value != 0 ? VolumeText(rendererContext.cell.value / 10, suffix: '/min') : Text('-'),
              ),
              '_id': TrinaCell(value: dive.id), // Hidden field for navigation
            },
          );
        }).toList();
        return TrinaGrid(
          key: ValueKey((state.preferences, dives)), // ensure recreation when preferences change... do we need to be more specific?
          columns: columns,
          rows: rows,
          mode: .selectWithOneTap,
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
