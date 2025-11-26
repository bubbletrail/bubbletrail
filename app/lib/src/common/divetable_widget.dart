import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../ssrf/ssrf.dart';

class DiveTableWidget extends StatelessWidget {
  final List<Dive> dives;
  final List<Divesite> diveSites;
  final bool showSiteColumn;

  const DiveTableWidget({super.key, required this.dives, required this.diveSites, this.showSiteColumn = true});

  @override
  Widget build(BuildContext context) {
    if (dives.isEmpty) {
      return const Center(child: Text('No dives to display'));
    }

    final columns = [
      const DataColumn(label: Text('Dive #')),
      const DataColumn(label: Text('Date')),
      const DataColumn(label: Text('Time')),
      const DataColumn(label: Text('Max Depth (m)')),
      const DataColumn(label: Text('Duration')),
      if (showSiteColumn) const DataColumn(label: Text('Site')),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          dividerThickness: 0,
          dataRowMinHeight: 24,
          dataRowMaxHeight: 32,
          showCheckboxColumn: false,
          rows: dives.map((dive) {
            final maxDepth = dive.divecomputers.isNotEmpty ? dive.divecomputers[0].maxDepth : 0.0;
            final diveSite = dive.divesiteid != null ? diveSites.where((s) => s.uuid.trim() == dive.divesiteid).firstOrNull : null;
            final siteName = diveSite?.name ?? '';

            final cells = [
              DataCell(Text(dive.number.toString())),
              DataCell(Text(DateFormat('yyyy-MM-dd').format(dive.start))),
              DataCell(Text(DateFormat('HH:mm').format(dive.start))),
              DataCell(Text(maxDepth.toStringAsFixed(1))),
              DataCell(Text(formatDuration(dive.duration))),
              if (showSiteColumn) DataCell(Text(siteName)),
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
