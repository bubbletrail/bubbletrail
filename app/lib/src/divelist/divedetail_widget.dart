import 'package:divepath/src/divelist/divelist_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../ssrf/ssrf.dart';
import 'common_widgets.dart';
import 'depth_profile_widget.dart';
import 'divesite_card_widget.dart';

class DiveDetailScreen extends StatelessWidget {
  final String diveID;

  const DiveDetailScreen({super.key, required this.diveID});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiveListBloc, DiveListState>(
      builder: (context, state) {
        if (state is! DiveListLoaded) {
          return Placeholder();
        }
        final diveIdx = state.dives.indexWhere((d) => d.id == diveID);
        final dive = state.dives[diveIdx];
        final diveSite = state.diveSites.firstWhere((s) => s.uuid == dive.divesiteid);
        final nextDiveID = diveIdx < state.dives.length - 1 ? state.dives[diveIdx + 1].id : null;
        final prevDiveID = diveIdx > 0 ? state.dives[diveIdx - 1].id : null;
        return DiveDetails(dive: dive, diveSite: diveSite, nextID: nextDiveID, prevID: prevDiveID);
      },
    );
  }
}

class DiveDetails extends StatelessWidget {
  final Dive dive;
  final Divesite diveSite;
  final String? nextID;
  final String? prevID;

  const DiveDetails({super.key, required this.dive, required this.diveSite, required this.nextID, required this.prevID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Dive #${dive.number}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/dives/${dive.id}/edit');
            },
            tooltip: 'Edit dive',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: prevID != null
                ? () {
                    context.go('/dives/${prevID!}');
                  }
                : null,
            tooltip: 'Previous dive',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: nextID != null
                ? () {
                    context.go('/dives/${nextID!}');
                  }
                : null,
            tooltip: 'Next dive',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          return SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16.0), child: isWideScreen ? _buildWideLayout(context) : _buildNarrowLayout(context)),
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildAllSections(context));
  }

  Widget _buildWideLayout(BuildContext context) {
    final sections = _buildAllSections(context);
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    // Separate sections that should be full width
    final fullWidthSections = <Widget>[];
    final regularSections = <Widget>[];

    for (final section in sections) {
      if (section is Card && section.child is Padding) {
        final padding = section.child as Padding;
        if (padding.child is Column) {
          final column = padding.child as Column;
          final children = column.children;
          if (children.isNotEmpty && children.first is Text) {
            final text = children.first as Text;
            if (text.data == 'Depth Profile') {
              fullWidthSections.add(section);
              continue;
            }
          }
        }
      }
      if (section is SizedBox) continue; // Skip spacing
      regularSections.add(section);
    }

    // Distribute regular sections into two columns
    for (var i = 0; i < regularSections.length; i++) {
      if (i.isEven) {
        leftColumn.add(regularSections[i]);
        leftColumn.add(const SizedBox(height: 16));
      } else {
        rightColumn.add(regularSections[i]);
        rightColumn.add(const SizedBox(height: 16));
      }
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: leftColumn),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rightColumn),
            ),
          ],
        ),
        ...fullWidthSections,
      ],
    );
  }

  List<Widget> _buildAllSections(BuildContext context) {
    return [
      buildInfoCard(context, 'General Information', [
        buildInfoRow('Date', DateFormat('yyyy-MM-dd').format(dive.start)),
        buildInfoRow('Time', DateFormat('HH:mm:ss').format(dive.start)),
        buildInfoRow('Duration', formatDuration(dive.duration)),
        if (dive.rating != null) buildInfoRow('Rating', '★' * dive.rating!),
        if (dive.tags.isNotEmpty) buildInfoRow('Tags', dive.tags.join(', ')),
      ]),
      const SizedBox(height: 16),
      ...[DiveSiteCardWidget(divesite: diveSite), const SizedBox(height: 16)],
      if (dive.divecomputers.isNotEmpty) ...[
        buildInfoCard(context, 'Dive Computer Data', [
          buildInfoRow('Max Depth', '${dive.divecomputers[0].maxDepth.toStringAsFixed(1)} m'),
          buildInfoRow('Mean Depth', '${dive.divecomputers[0].meanDepth.toStringAsFixed(1)} m'),
          if (dive.divecomputers[0].environment?.airTemperature != null)
            buildInfoRow('Air Temperature', '${dive.divecomputers[0].environment!.airTemperature!.toStringAsFixed(1)} °C'),
          if (dive.divecomputers[0].environment?.waterTemperature != null)
            buildInfoRow('Water Temperature', '${dive.divecomputers[0].environment!.waterTemperature!.toStringAsFixed(1)} °C'),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.sac != null || dive.otu != null || dive.cns != null) ...[
        buildInfoCard(context, 'Physiological Data', [
          if (dive.sac != null) buildInfoRow('SAC', '${dive.sac!.toStringAsFixed(1)} l/min'),
          if (dive.otu != null) buildInfoRow('OTU', dive.otu.toString()),
          if (dive.cns != null) buildInfoRow('CNS', '${dive.cns}%'),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.divemaster != null || dive.buddies.isNotEmpty) ...[
        buildInfoCard(context, 'People', [
          if (dive.divemaster != null) buildInfoRow('Divemaster', dive.divemaster!),
          if (dive.buddies.isNotEmpty) buildInfoRow('Buddies', dive.buddies.join(', ')),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.cylinders.isNotEmpty) ...[
        buildInfoCard(
          context,
          'Cylinders',
          dive.cylinders.asMap().entries.map((entry) {
            final idx = entry.key;
            final cyl = entry.value;
            final desc = cyl.description ?? 'Cylinder ${idx + 1}';
            final details = <String>[];

            // Gas mixture
            if (cyl.o2 != null || cyl.he != null) {
              final o2 = cyl.o2 ?? 21.0;
              final he = cyl.he ?? 0.0;
              if (he > 0) {
                details.add('Tx${o2.toStringAsFixed(0)}/${he.toStringAsFixed(0)}');
              } else if (o2 != 21.0) {
                details.add('EAN${o2.toStringAsFixed(0)}');
              } else {
                details.add('Air');
              }
            }

            if (cyl.size != null) details.add('${cyl.size!.toStringAsFixed(1)} l');
            if (cyl.workpressure != null) details.add('${cyl.workpressure!.toStringAsFixed(0)} bar');
            if (cyl.start != null) details.add('Start: ${cyl.start!.toStringAsFixed(0)} bar');
            if (cyl.end != null) details.add('End: ${cyl.end!.toStringAsFixed(0)} bar');
            return buildInfoRow(desc, details.join(', '));
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
      if (dive.weightsystems.isNotEmpty) ...[
        buildInfoCard(
          context,
          'Weight Systems',
          dive.weightsystems.asMap().entries.map((entry) {
            final idx = entry.key;
            final ws = entry.value;
            final desc = ws.description ?? 'Weight ${idx + 1}';
            final weight = ws.weight != null ? '${ws.weight!.toStringAsFixed(1)} kg' : '';
            return buildInfoRow(desc, weight);
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
      if (dive.notes != null && dive.notes!.isNotEmpty) ...[
        buildInfoCard(context, 'Notes', [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(dive.notes!, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.divecomputers.isNotEmpty && dive.divecomputers[0].samples.isNotEmpty) ...[
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Depth Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(),
                DepthProfileWidget(diveComputer: dive.divecomputers[0]),
              ],
            ),
          ),
        ),
      ],
    ];
  }
}
