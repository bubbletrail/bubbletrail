import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:protobuf/protobuf.dart';

import '../app_routes.dart';
import '../bloc/divedetails_bloc.dart';
import '../bloc/divelist_bloc.dart';
import '../common/common.dart';
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
          final diveIdx = listState.diveIndexById[state.dive.id];
          if (diveIdx != null) {
            nextDiveID = diveIdx < listState.dives.length - 1 ? listState.dives[diveIdx + 1].id : null;
            prevDiveID = diveIdx > 0 ? listState.dives[diveIdx - 1].id : null;
          }
        }

        return _DiveDetails(dive: state.dive, site: state.site, nextID: nextDiveID, prevID: prevDiveID);
      },
    );
  }
}

class _DiveDetails extends StatelessWidget {
  final Dive dive;
  final Site? site;
  final String? nextID;
  final String? prevID;

  const _DiveDetails({required this.dive, required this.site, required this.nextID, required this.prevID});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text('Dive #${dive.number}: ${site?.name ?? 'Unknown site'}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.goNamed(AppRouteName.divesDetailsEdit, pathParameters: {'diveID': dive.id});
          },
          tooltip: 'Edit dive',
        ),
        IconButton(
          icon: const Icon(Icons.arrow_upward),
          onPressed: prevID != null
              ? () {
                  context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': prevID!});
                }
              : null,
          tooltip: 'Previous dive',
        ),
        IconButton(
          icon: const Icon(Icons.arrow_downward),
          onPressed: nextID != null
              ? () {
                  context.goNamed(AppRouteName.divesDetails, pathParameters: {'diveID': nextID!});
                }
              : null,
          tooltip: 'Next dive',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'debug') {
              showDialog(
                context: context,
                builder: (context) => _RawDiveDataScreen(dive: dive),
              );
            }
          },
          itemBuilder: (context) => [const PopupMenuItem(value: 'debug', child: Text('Raw Dive Data'))],
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

  DateTime get _startDateTime => dive.start.toDateTime();

  List<Widget> _buildAllSections(BuildContext context) {
    return [
      infoCard(context, 'General Information', [
        infoRow('Start', DateFormat.yMd().add_jm().format(_startDateTime)),
        infoRow('Duration', formatDuration(dive.duration)),
        if (dive.hasRating()) infoRow('Rating', '★' * dive.rating),
        tagsRow(context, dive.tags.toList(), secondaryTags: site?.tags.where((t) => !dive.tags.contains(t)).toList()),
      ]),
      const SizedBox(height: 16),
      if (site != null) ...[_SiteCard(site: site!), const SizedBox(height: 16)],
      if (dive.logs.isNotEmpty) ...[
        infoCard(context, 'Dive Computer Data', [
          if (dive.logs[0].hasMaxDepth()) infoWidgetRow('Max Depth', DepthText(dive.logs[0].maxDepth)),
          if (dive.logs[0].hasAvgDepth()) infoWidgetRow('Mean Depth', DepthText(dive.logs[0].avgDepth)),
          if (dive.logs[0].hasSurfaceTemperature()) infoWidgetRow('Air Temperature', TemperatureText(dive.logs[0].surfaceTemperature)),
          if (dive.logs[0].hasMinTemperature()) infoWidgetRow('Water Temperature', TemperatureText(dive.logs[0].minTemperature)),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.hasSac() || dive.hasOtu() || dive.hasCns()) ...[
        infoCard(context, 'Physiological Data', [
          if (dive.hasSac()) infoRow('SAC', '${dive.sac.toStringAsFixed(1)} l/min'),
          if (dive.hasOtu()) infoRow('OTU', dive.otu.toString()),
          if (dive.hasCns()) infoRow('CNS', '${dive.cns}%'),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.divemaster.isNotEmpty || dive.buddies.isNotEmpty) ...[
        infoCard(context, 'People', [
          if (dive.divemaster.isNotEmpty) infoRow('Divemaster', dive.divemaster),
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
            final desc = cyl.hasCylinder() && cyl.cylinder.description.isNotEmpty ? cyl.cylinder.description : 'Cylinder ${idx + 1}';
            final details = <String>[];

            // Gas mixture
            if (cyl.hasOxygen() || cyl.hasHelium()) {
              final o2 = cyl.hasOxygen() ? cyl.oxygen : 0.21;
              if (cyl.helium > 0) {
                details.add('Tx${(o2 * 100).toStringAsFixed(0)}/${(cyl.helium * 100).toStringAsFixed(0)}');
              } else if (o2 != 0.21) {
                details.add('EAN${(o2 * 100).toStringAsFixed(0)}');
              } else {
                details.add('Air');
              }
            }

            if (cyl.hasCylinder() && cyl.cylinder.hasSize()) details.add(formatVolume(context, cyl.cylinder.size));
            if (cyl.hasCylinder() && cyl.cylinder.hasWorkpressure()) details.add(formatPressure(context, cyl.cylinder.workpressure));
            if (cyl.hasBeginPressure()) details.add('Start: ${formatPressure(context, cyl.beginPressure)}');
            if (cyl.hasEndPressure()) details.add('End: ${formatPressure(context, cyl.endPressure)}');
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
            final desc = ws.description.isNotEmpty ? ws.description : 'Weight ${idx + 1}';
            final weight = ws.hasWeight() ? formatWeight(context, ws.weight) : '';
            return infoRow(desc, weight);
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
      if (dive.notes.isNotEmpty) ...[
        infoCard(context, 'Notes', [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(dive.notes, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ]),
        const SizedBox(height: 16),
      ],
      if (dive.logs.isNotEmpty && dive.logs[0].samples.isNotEmpty) ...[
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
                            builder: (context) => FullscreenProfileScreen(log: dive.logs[0], title: 'Dive #${dive.number}'),
                          ),
                        );
                      },
                      tooltip: 'View fullscreen',
                    ),
                  ],
                ),
                const Divider(),
                DepthProfileWidget(log: dive.logs[0]),
              ],
            ),
          ),
        ),
      ],
    ];
  }
}

class _SiteCard extends StatelessWidget {
  final Site site;

  const _SiteCard({required this.site});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': site.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview (only if position exists)
            if (site.hasPosition()) SizedBox(height: 150, child: SiteMap(position: site.position)),
            // Site information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(site.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                  const Divider(),
                  if (site.hasPosition()) ...[
                    infoRow('Latitude', site.position.latitude.toStringAsFixed(6)),
                    infoRow('Longitude', site.position.longitude.toStringAsFixed(6)),
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

class _RawDiveDataScreen extends StatelessWidget {
  final Dive dive;

  const _RawDiveDataScreen({required this.dive});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(dive.toTextFormat(), style: Theme.of(context).textTheme.bodyMedium?.apply(fontFamily: 'Courier')),
      ),
    );
  }
}
