import 'dart:io';

import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:protobuf/protobuf.dart';

import '../app_routes.dart';
import '../bloc/divelist_bloc.dart';
import '../bloc/preferences_bloc.dart';
import '../common/common.dart';
import 'depthprofile_widget.dart';

class DiveDetailsScreen extends StatelessWidget {
  const DiveDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiveListBloc, DiveListState>(
      builder: (context, state) {
        if (state is! DiveListLoaded || state.selectedDive == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final dive = state.selectedDive!;
        final site = state.selectedDiveSite;

        String? nextDiveID;
        String? prevDiveID;

        final diveIdx = state.diveIndexById[dive.id];
        if (diveIdx != null) {
          nextDiveID = diveIdx < state.dives.length - 1 ? state.dives[diveIdx + 1].id : null;
          prevDiveID = diveIdx > 0 ? state.dives[diveIdx - 1].id : null;
        }

        return _DiveDetails(dive: dive, site: site, nextID: nextDiveID, prevID: prevDiveID);
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
          onSelected: (value) async {
            if (value == 'debug') {
              await showDialog(
                context: context,
                builder: (context) => _RawDiveDataScreen(dive: dive),
              );
            } else if (value == 'delete') {
              final confirmed = await showConfirmationDialog(
                context: context,
                title: 'Delete Dive',
                message: 'Are you sure you want to delete dive #${dive.number}? This cannot be undone.',
                confirmText: 'Delete',
                isDestructive: true,
              );
              if (confirmed && context.mounted) {
                context.read<DiveListBloc>().add(DeleteDive(dive.id));
                context.goNamed(AppRouteName.dives);
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'debug', child: Text('View Raw Data')),
            const PopupMenuItem(value: 'delete', child: Text('Delete Dive')),
          ],
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          return SingleChildScrollView(child: isWideScreen ? _buildWideLayout(context) : _buildNarrowLayout(context));
        },
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: _buildAllSections(context)),
    );
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
      } else {
        rightColumn.add(regularSections[i]);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 8,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Expanded(
                child: Column(spacing: 8, crossAxisAlignment: CrossAxisAlignment.start, children: leftColumn),
              ),
              Expanded(
                child: Column(spacing: 8, crossAxisAlignment: CrossAxisAlignment.start, children: rightColumn),
              ),
            ],
          ),
          ...fullWidthSections,
        ],
      ),
    );
  }

  DateTime get _startDateTime => dive.start.toDateTime();

  List<Widget> _buildAllSections(BuildContext context) {
    return [
      infoCard(context, 'General Information', [
        infoWidgetRow('Start', DateTimeText(_startDateTime)),
        infoRow('Duration', formatDuration(dive.duration)),
        if (dive.hasRating()) infoRow('Rating', '★' * dive.rating),
        tagsRow(context, dive.tags.toList(), secondaryTags: site?.tags.where((t) => !dive.tags.contains(t)).toList()),
      ]),
      if (site != null) _SiteCard(site: site!),
      infoCard(context, 'Dive Computer Data', [
        if (dive.hasMaxDepth()) infoWidgetRow('Max Depth', DepthText(dive.maxDepth)),
        if (dive.hasMeanDepth()) infoWidgetRow('Mean Depth', DepthText(dive.meanDepth)),
        if (dive.logs.isNotEmpty) ...[
          if (dive.logs[0].hasSurfaceTemperature()) infoWidgetRow('Air Temperature', TemperatureText(dive.logs[0].surfaceTemperature)),
          if (dive.logs[0].hasMinTemperature()) infoWidgetRow('Water Temperature', TemperatureText(dive.logs[0].minTemperature)),
        ],
      ]),
      if (dive.hasSac() || dive.hasOtu() || dive.hasCns()) ...[
        infoCard(context, 'Physiological Data', [
          if (dive.hasSac()) infoWidgetRow('SAC', VolumeText(dive.sac, suffix: '/min')),
          if (dive.hasOtu()) infoRow('OTU', dive.otu.toString()),
          if (dive.hasCns()) infoRow('CNS', '${dive.cns}%'),
        ]),
      ],
      if (dive.divemaster.isNotEmpty || dive.buddies.isNotEmpty) ...[
        infoCard(context, 'People', [
          if (dive.divemaster.isNotEmpty) infoRow('Divemaster', dive.divemaster),
          if (dive.buddies.isNotEmpty) infoRow('Buddies', dive.buddies.join(', ')),
        ]),
      ],
      if (dive.cylinders.isNotEmpty) ...[
        infoCard(
          context,
          'Cylinders',
          dive.cylinders.indexed.map((entry) {
            final idx = entry.$1;
            final cyl = entry.$2;
            return CylinderTile(
              index: idx,
              description: cyl.cylinder.description,
              oxygenPct: (cyl.oxygen * 100).toInt(),
              heliumPct: (cyl.helium * 100).toInt(),
              beginPressure: cyl.beginPressure,
              endPressure: cyl.endPressure,
              sac: cyl.sac,
            );
          }).toList(),
        ),
      ],
      if (dive.weightsystems.isNotEmpty) ...[
        infoCard(
          context,
          'Weight Systems',
          dive.weightsystems.asMap().entries.map((entry) {
            final idx = entry.key;
            final ws = entry.value;
            final desc = ws.description.isNotEmpty ? ws.description : 'Weight ${idx + 1}';
            return infoWidgetRow(desc, WeightText(ws.weight));
          }).toList(),
        ),
      ],
      if (dive.notes.isNotEmpty) ...[
        infoCard(context, 'Notes', [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(dive.notes, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ]),
      ],
      if (dive.logs.isNotEmpty && dive.logs[0].samples.isNotEmpty) ...[
        _WideCard(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Depth Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () {
                        context.pushNamed(AppRouteName.divesDetailsDepthProfile, pathParameters: {'diveID': dive.id});
                      },
                      tooltip: 'View fullscreen',
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                IgnorePointer(
                  ignoring: Platform.isIOS,
                  child: AspectRatio(
                    aspectRatio: 2.0,
                    child: BlocBuilder<PreferencesBloc, PreferencesState>(
                      builder: (context, state) {
                        return DepthProfileWidget(key: ValueKey((dive, state.preferences)), log: dive.logs[0], preferences: state.preferences);
                      },
                    ),
                  ),
                ),
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
            if (site.hasPosition())
              Stack(
                children: [
                  SizedBox(
                    height: 150,
                    child: IgnorePointer(child: SiteMap(position: LatLng(site.position.latitude, site.position.longitude))),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () {
                        context.pushNamed(AppRouteName.sitesDetailsMap, pathParameters: {'siteID': site.id});
                      },
                      tooltip: 'View fullscreen',
                    ),
                  ),
                ],
              ),
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
                  if (site.hasCountry()) infoRow('Country', site.country),
                  if (site.hasCountry()) infoRow('Location', site.location),
                  if (site.bodyOfWater.isNotEmpty) infoRow('Body of Water', site.bodyOfWater),
                  if (site.hasPosition()) infoRow('Position', [formatLatitude(site.position.latitude), formatLongitude(site.position.longitude)].join(' ')),
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
