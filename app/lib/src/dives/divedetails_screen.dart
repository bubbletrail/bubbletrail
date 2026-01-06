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

    final fullWidthSections = <Widget>[];
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (final section in sections) {
      if (section is _Positioned) {
        switch (section.position) {
          case _Position.wide:
            fullWidthSections.add(section);
          case _Position.left:
            leftColumn.add(section);
          case _Position.right:
            rightColumn.add(section);
        }
      } else {
        leftColumn.add(section);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 8,
        children: [
          ...fullWidthSections,
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
        ],
      ),
    );
  }

  List<Widget> _buildAllSections(BuildContext context) {
    return [
      if (dive.logs.isNotEmpty && dive.logs[0].samples.isNotEmpty)
        _Positioned(
          position: _Position.wide,
          child: _ProfileCard(dive: dive, site: site),
        ),
      if (dive.notes.isNotEmpty)
        _Positioned(
          position: _Position.wide,
          child: infoCard(context, 'Notes', [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(dive.notes, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ]),
        ),
      if (site != null)
        _Positioned(
          position: _Position.left,
          child: _SiteCard(site: site!),
        ),
      if (dive.divemaster.isNotEmpty || dive.buddies.isNotEmpty)
        _Positioned(
          position: _Position.right,
          child: infoCard(context, 'People', [
            if (dive.divemaster.isNotEmpty) infoRow('Divemaster', dive.divemaster),
            if (dive.buddies.isNotEmpty) infoRow('Buddies', dive.buddies.join(', ')),
          ]),
        ),
      if (dive.cylinders.isNotEmpty)
        _Positioned(
          position: _Position.right,
          child: infoCard(
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
        ),
      if (dive.weightsystems.isNotEmpty)
        _Positioned(
          position: _Position.right,
          child: infoCard(
            context,
            'Weights',
            dive.weightsystems.asMap().entries.map((entry) {
              final idx = entry.key;
              final ws = entry.value;
              final desc = ws.description.isNotEmpty ? ws.description : 'Weight ${idx + 1}';
              return infoWidgetRow(desc, WeightText(ws.weight));
            }).toList(),
          ),
        ),
    ];
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.dive, required this.site});

  final Dive dive;
  final Site? site;

  @override
  Widget build(BuildContext context) {
    final worstDeco = dive.logs.isNotEmpty ? dive.logs.first.worstDecoStatus : null;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Dive profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              spacing: 8,
              children: [
                _Labeled(label: 'Start', child: DateTimeText(dive.start.toDateTime())),
                _Labeled(label: 'Duration', child: DurationText(dive.duration)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: IgnorePointer(
                ignoring: Platform.isIOS,
                child: AspectRatio(
                  aspectRatio: 3.0,
                  child: BlocBuilder<PreferencesBloc, PreferencesState>(
                    builder: (context, state) {
                      return DepthProfileWidget(key: ValueKey((dive, state.preferences)), log: dive.logs[0], preferences: state.preferences);
                    },
                  ),
                ),
              ),
            ),
            Wrap(
              // alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              spacing: 8,
              children: [
                TagsList(tags: dive.tags, secondaryTags: site?.tags.where((t) => !dive.tags.contains(t)).toList(), prefix: '#'),
                Text('★' * dive.rating),
                if (dive.hasMaxDepth()) _Labeled(label: 'Max', child: DepthText(dive.maxDepth)),
                if (dive.hasMeanDepth()) _Labeled(label: 'Mean', child: DepthText(dive.meanDepth)),
                if (worstDeco != null) _Labeled(label: 'Deco', child: DecoStatusText(worstDeco)),
                if (dive.hasMaxTemp() || dive.hasMinTemp()) _Temps(dive),
                if (dive.hasOtu()) _Labeled(label: 'OTU', child: Text(dive.otu.toString())),
                if (dive.hasSac())
                  _Labeled(
                    label: 'SAC',
                    child: VolumeText(dive.sac, suffix: '/min'),
                  ),
                if (dive.hasOtu()) _Labeled(label: 'OTU', child: Text(dive.otu.toString())),
                if (dive.hasCns()) _Labeled(label: 'CNS', child: Text('${dive.cns}%')),
                if (dive.logs.isNotEmpty) ...[if (dive.logs[0].hasDecoModel()) _Labeled(label: 'Model', child: DecoModelText(dive.logs[0].decoModel))],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Temps extends StatelessWidget {
  const _Temps(this.dive);

  final Dive dive;

  @override
  Widget build(BuildContext context) {
    if (dive.hasMinTemp() && dive.hasMaxDepth() && dive.minTemp != dive.maxTemp) {
      return _Labeled(
        label: 'Temp',
        child: Row(
          children: [
            TemperatureText(dive.minTemp),
            Opacity(opacity: 0.5, child: Text(' - ')),
            TemperatureText(dive.maxTemp),
          ],
        ),
      );
    }
    if (dive.hasMaxTemp()) {
      return _Labeled(label: 'Temp', child: TemperatureText(dive.maxTemp));
    }
    if (dive.hasMinTemp()) {
      return _Labeled(label: 'Temp', child: TemperatureText(dive.minTemp));
    }
    return const SizedBox();
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inner = (label == null)
        ? child
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Opacity(opacity: 0.7, child: Text(label!, style: Theme.of(context).textTheme.labelSmall)),
              child,
            ],
          );
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      label: inner,
    );
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

enum _Position { left, right, wide }

class _Positioned extends StatelessWidget {
  const _Positioned({required this.position, required this.child});

  final _Position position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
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
