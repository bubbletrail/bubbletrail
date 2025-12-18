import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app_routes.dart';
import '../bloc/divedetails_bloc.dart';
import '../bloc/divelist_bloc.dart';
import '../common/common.dart';
import '../ssrf/ssrf.dart' as ssrf;
import 'depthprofile_widget.dart';
import 'fullscreen_profile_screen.dart';

class DiveDetailsScreen extends StatelessWidget {
  const DiveDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get prev/next dive IDs from the overview list
    final listState = context.watch<DiveListBloc>().state;
    return BlocBuilder<DiveDetailsBloc, DiveDetailsState>(
      builder: (context, state) {
        state as DiveDetailsLoaded;

        String? nextDiveID;
        String? prevDiveID;

        if (listState is DiveListLoaded) {
          final diveIdx = listState.dives.indexWhere((d) => d.id == state.dive.id);
          if (diveIdx != -1) {
            nextDiveID = diveIdx < listState.dives.length - 1 ? listState.dives[diveIdx + 1].id : null;
            prevDiveID = diveIdx > 0 ? listState.dives[diveIdx - 1].id : null;
          }
        }

        return _DiveDetails(dive: state.dive, diveSite: state.diveSite, nextID: nextDiveID, prevID: prevDiveID);
      },
    );
  }
}

class _DiveDetails extends StatelessWidget {
  final ssrf.Dive dive;
  final ssrf.Divesite? diveSite;
  final String? nextID;
  final String? prevID;

  const _DiveDetails({required this.dive, required this.diveSite, required this.nextID, required this.prevID});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text('Dive #${dive.number}: ${diveSite?.name ?? 'Unknown site'}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.goNamed(AppRouteName.divesDetailsEdit, pathParameters: {'diveID': dive.id});
          },
          tooltip: 'Edit dive',
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: prevID != null
              ? () {
                  context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': prevID!});
                }
              : null,
          tooltip: 'Previous dive',
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: nextID != null
              ? () {
                  context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': nextID!});
                }
              : null,
          tooltip: 'Next dive',
        ),
      ],
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
      if (section is _WideCard) {
        fullWidthSections.add(section);
        continue;
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
      infoCard(context, 'General Information', [
        infoRow('Start', DateFormat.yMd().add_jm().format(dive.start)),
        infoRow('Duration', ssrf.formatDuration(dive.duration)),
        if (dive.rating != null) infoRow('Rating', '★' * dive.rating!),
        if (dive.tags.isNotEmpty) infoRow('Tags', dive.tags.join(', ')),
      ]),
      const SizedBox(height: 16),
      if (diveSite != null) ...[_DivesiteCard(divesite: diveSite!), const SizedBox(height: 16)],
      if (dive.divecomputers.isNotEmpty) ...[
        infoCard(context, 'Dive Computer Data', [
          infoRow('Max Depth', '${dive.divecomputers[0].maxDepth.toStringAsFixed(1)} m'),
          infoRow('Mean Depth', '${dive.divecomputers[0].meanDepth.toStringAsFixed(1)} m'),
          if (dive.divecomputers[0].environment?.airTemperature != null)
            infoRow('Air Temperature', '${dive.divecomputers[0].environment!.airTemperature!.toStringAsFixed(1)} °C'),
          if (dive.divecomputers[0].environment?.waterTemperature != null)
            infoRow('Water Temperature', '${dive.divecomputers[0].environment!.waterTemperature!.toStringAsFixed(1)} °C'),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.sac != null || dive.otu != null || dive.cns != null) ...[
        infoCard(context, 'Physiological Data', [
          if (dive.sac != null) infoRow('SAC', '${dive.sac!.toStringAsFixed(1)} l/min'),
          if (dive.otu != null) infoRow('OTU', dive.otu.toString()),
          if (dive.cns != null) infoRow('CNS', '${dive.cns}%'),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.divemaster != null || dive.buddies.isNotEmpty) ...[
        infoCard(context, 'People', [
          if (dive.divemaster != null) infoRow('Divemaster', dive.divemaster!),
          if (dive.buddies.isNotEmpty) infoRow('Buddies', dive.buddies.join(', ')),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.cylinders.isNotEmpty) ...[
        infoCard(
          context,
          'Cylinders',
          dive.cylinders.asMap().entries.map((entry) {
            final idx = entry.key;
            final cyl = entry.value;
            final desc = cyl.cylinder?.description ?? 'Cylinder ${idx + 1}';
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

            if (cyl.cylinder?.size != null) details.add('${cyl.cylinder!.size!.toStringAsFixed(1)} l');
            if (cyl.cylinder?.workpressure != null) details.add('${cyl.cylinder!.workpressure!.toStringAsFixed(0)} bar');
            if (cyl.start != null) details.add('Start: ${cyl.start!.toStringAsFixed(0)} bar');
            if (cyl.end != null) details.add('End: ${cyl.end!.toStringAsFixed(0)} bar');
            return infoRow(desc, details.join(', '));
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
      if (dive.weightsystems.isNotEmpty) ...[
        infoCard(
          context,
          'Weight Systems',
          dive.weightsystems.asMap().entries.map((entry) {
            final idx = entry.key;
            final ws = entry.value;
            final desc = ws.description ?? 'Weight ${idx + 1}';
            final weight = ws.weight != null ? '${ws.weight!.toStringAsFixed(1)} kg' : '';
            return infoRow(desc, weight);
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
      if (dive.notes != null && dive.notes!.isNotEmpty) ...[
        infoCard(context, 'Notes', [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(dive.notes!, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.divecomputers.isNotEmpty && dive.divecomputers[0].samples.isNotEmpty) ...[
        _WideCard(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Depth Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => FullscreenProfileScreen(diveComputerLog: dive.divecomputers[0], title: 'Dive #${dive.number}'),
                          ),
                        );
                      },
                      tooltip: 'View fullscreen',
                    ),
                  ],
                ),
                const Divider(),
                DepthProfileWidget(diveComputerLog: dive.divecomputers[0]),
              ],
            ),
          ),
        ),
      ],
    ];
  }
}

class _DivesiteCard extends StatelessWidget {
  final ssrf.Divesite divesite;

  const _DivesiteCard({required this.divesite});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': divesite.uuid});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview (only if position exists)
            if (divesite.position != null) SizedBox(height: 150, child: DiveSiteMap(position: divesite.position!)),
            // Site information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(divesite.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                  const Divider(),
                  if (divesite.position != null) ...[
                    infoRow('Latitude', divesite.position!.lat.toStringAsFixed(6)),
                    infoRow('Longitude', divesite.position!.lon.toStringAsFixed(6)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: unused_element_parameter
class _WideCard extends Card {
  const _WideCard({
    super.key,
    super.color,
    super.shadowColor,
    super.surfaceTintColor,
    super.elevation,
    super.shape,
    super.borderOnForeground,
    super.margin,
    super.clipBehavior,
    super.child,
    super.semanticContainer,
  });
}
