import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../ssrf/ssrf.dart' as ssrf;

class DiveTableWidget extends StatefulWidget {
  final List<ssrf.Dive> dives;
  final List<ssrf.Divesite> diveSites;
  final bool showSiteColumn;

  const DiveTableWidget({super.key, required this.dives, required this.diveSites, this.showSiteColumn = true});

  @override
  State<DiveTableWidget> createState() => _DiveTableWidgetState();
}

class _DiveTableWidgetState extends State<DiveTableWidget> {
  int _sortColumnIndex = 1;
  bool _sortAscending = false;

  List<ssrf.Dive> _getSortedDives() {
    var comparison = (ssrf.Dive a, ssrf.Dive b) => a.number.compareTo(b.number);

    switch (_sortColumnIndex) {
      case 0: // Dive #
        // already set
        break;
      case 1: // Date
        comparison = (a, b) => a.start.compareTo(b.start);
        break;
      case 2: // Max Depth
        comparison = (a, b) {
          final aDepth = a.maxDepth ?? 0.0;
          final bDepth = b.maxDepth ?? 0.0;
          return aDepth.compareTo(bDepth);
        };
        break;
      case 3: // Duration
        comparison = (a, b) => a.duration.compareTo(b.duration);
        break;
      case 4: // Site (only if showSiteColumn is true)
        comparison = (a, b) {
          final aSite = a.divesiteid != null ? widget.diveSites.where((s) => s.uuid.trim() == a.divesiteid).firstOrNull : null;
          final bSite = b.divesiteid != null ? widget.diveSites.where((s) => s.uuid.trim() == b.divesiteid).firstOrNull : null;
          final aSiteName = aSite?.name ?? '';
          final bSiteName = bSite?.name ?? '';
          return aSiteName.compareTo(bSiteName);
        };
        break;
    }

    final sortedDives = List<ssrf.Dive>.from(widget.dives);
    if (_sortAscending) {
      sortedDives.sort(comparison);
    } else {
      sortedDives.sort((a, b) => -comparison(a, b));
    }
    return sortedDives;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dives.isEmpty) {
      return const Center(child: Text('No dives to display'));
    }

    final columns = [
      DataColumn(label: const Text('Dive #'), onSort: _onSort),
      DataColumn(label: const Text('Start'), onSort: _onSort),
      DataColumn(label: const Text('Max Depth (m)'), onSort: _onSort),
      DataColumn(label: const Text('Duration'), onSort: _onSort),
      if (widget.showSiteColumn) DataColumn(label: const Text('Site'), onSort: _onSort),
    ];

    final t = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          dividerThickness: 0,
          dataRowMinHeight: t.visualDensity == VisualDensity.compact ? 24 : 32,
          dataRowMaxHeight: t.visualDensity == VisualDensity.compact ? 32 : 48,
          columnSpacing: 8,
          showCheckboxColumn: false,
          rows: _getSortedDives().map((dive) {
            final maxDepth = dive.maxDepth ?? 0.0;
            final diveSite = dive.divesiteid != null ? widget.diveSites.where((s) => s.uuid.trim() == dive.divesiteid).firstOrNull : null;
            final siteName = diveSite?.name ?? '';

            final cells = [
              DataCell(Text(dive.number.toString())),
              DataCell(Text(DateFormat.yMd().add_jm().format(dive.start))),
              DataCell(Text(maxDepth.toStringAsFixed(1))),
              DataCell(Text(ssrf.formatDuration(dive.duration))),
              if (widget.showSiteColumn) DataCell(Text(siteName)),
            ];

            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true) {
                  context.go('/dives/${dive.id}');
                }
              },
              cells: cells,
            );
          }).toList(),
        ),
      ),
    );
  }
}
