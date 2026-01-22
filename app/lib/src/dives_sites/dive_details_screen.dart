import 'dart:convert';

import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart' hide DataColumn;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../common/common.dart';
import '../preferences/preferences_bloc.dart';
import 'depth_profile_widget.dart';
import 'dive_details_bloc.dart';
import 'site_map.dart';

class DiveDetailsScreen extends StatelessWidget {
  const DiveDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiveDetailsBloc, DiveDetailsState>(
      builder: (context, state) {
        if (state is! DiveDetailsLoaded) {
          // Can't happen
          return Placeholder();
        }

        return _DiveDetails(dive: state.dive, site: state.site, nextDive: state.nextDive, prevDive: state.prevDive);
      },
    );
  }
}

class _DiveDetails extends StatelessWidget {
  final Dive dive;
  final Site? site;
  final Dive? nextDive;
  final Dive? prevDive;

  const _DiveDetails({required this.dive, this.site, this.nextDive, this.prevDive});

  @override
  Widget build(BuildContext context) {
    final title = platformIsDesktop ? 'Dive ' : '';
    return BlocBuilder<DiveDetailsBloc, DiveDetailsState>(
      builder: (context, state) {
        return ScreenScaffold(
          title: Text('$title#${dive.number}: ${site?.name ?? 'Unknown site'}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: prevDive != null
                  ? () {
                      context.read<DiveDetailsBloc>().add(DiveDetailsEvent.loadDive(prevDive!.id));
                    }
                  : null,
              tooltip: prevDive != null ? 'Dive #${prevDive?.number}' : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: nextDive != null
                  ? () {
                      context.read<DiveDetailsBloc>().add(DiveDetailsEvent.loadDive(nextDive!.id));
                    }
                  : null,
              tooltip: nextDive != null ? 'Dive #${nextDive?.number}' : null,
            ),
            if (platformIsDesktop)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.goNamed(AppRouteName.divesDetailsEdit, pathParameters: {'diveID': dive.id});
                },
                tooltip: 'Edit dive',
              ),
            if (platformIsDesktop) _popupMenuActions(context),
          ],
          body: SingleChildScrollView(
            child: Padding(
              padding: const .all(8.0),
              child: Column(crossAxisAlignment: .stretch, spacing: 8, children: _buildAllSections(context)),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAllSections(BuildContext context) {
    final datacolumns =
        (<Widget?>[_depthsTable(), _physioTable()] + _cylindersTables() + [if (dive.weightsystems.isNotEmpty) _weightsTable()])
            .where((w) => w != null)
            .map<Widget>(
              (t) => Card(
                child: Padding(padding: const .all(16.0), child: t),
              ),
            )
            .toList() +
        [
          if (site != null)
            ConstrainedBox(
              constraints: .loose(.fromWidth(600)),
              child: _SiteCard(site: site!),
            ),
        ];

    return [
      _MaybeCard(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            if (dive.logs.isNotEmpty && dive.logs[0].samples.isNotEmpty) _ProfileCard(dive: dive, site: site),
            _buddiesTagsEtc(),
          ],
        ),
      ),
      if (dive.notes.isNotEmpty)
        Card(
          child: Padding(padding: const .all(16.0), child: Text(dive.notes)),
        ),
      _WidthResponsive(
        narrow: Column(crossAxisAlignment: .stretch, spacing: 8, children: datacolumns),
        wide: Wrap(alignment: .start, crossAxisAlignment: .start, spacing: 8, runSpacing: 8, children: datacolumns),
      ),
      if (platformIsMobile)
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: .spaceBetween,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: Text('Edit dive'),
              onPressed: () {
                context.goNamed(AppRouteName.divesDetailsEdit, pathParameters: {'diveID': dive.id});
              },
            ),
            if (platformIsMobile) _popupMenuActions(context),
          ],
        ),
    ];
  }

  PopupMenuButton<String> _popupMenuActions(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'debug') {
          await showDialog(
            context: context,
            builder: (context) => _RawDiveDataScreen(dive: dive),
          );
        } else if (value == 'delete') {
          final confirmed = await showConfirmationDialog(
            context: context,
            title: 'Delete dive',
            message: 'Are you sure you want to delete dive #${dive.number}? This cannot be undone.',
            confirmText: 'Delete',
            isDestructive: true,
          );
          if (confirmed && context.mounted) {
            context.read<DiveDetailsBloc>().add(DiveDetailsEvent.deleteAndClose(dive.id));
            context.goNamed(AppRouteName.dives);
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'debug', child: Text('View raw data')),
        const PopupMenuItem(value: 'delete', child: Text('Delete dive')),
      ],
    );
  }

  Wrap _buddiesTagsEtc() {
    return Wrap(
      crossAxisAlignment: .center,
      runSpacing: 8,
      spacing: 24,
      children: [
        if (site != null) LabeledChip(label: 'Location', child: Text(site!.name)),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: dive.buddies.map<Widget>((b) => LabeledChip(label: 'Buddy', child: Text(b))).toList(),
        ),
        TagsList(tags: dive.tags, secondaryTags: site?.tags.where((t) => !dive.tags.contains(t)).toList(), prefix: '#'),
        Text('★' * dive.rating),
        if (dive.divemaster.isNotEmpty) LabeledChip(label: 'Divemaster', child: Text(dive.divemaster)),
      ],
    );
  }

  List<Widget> _cylindersTables() {
    return dive.cylinders.indexed.map<Widget>((entry) {
      final idx = entry.$1;
      final cyl = entry.$2;
      return _CylinderColumn(
        index: idx,
        description: cyl.cylinder.description,
        oxygenPct: (cyl.oxygen * 100).toInt(),
        heliumPct: (cyl.helium * 100).toInt(),
        beginPressure: cyl.beginPressure,
        endPressure: cyl.endPressure,
        volumeL: cyl.cylinder.volumeL,
        sac: cyl.sac,
      );
    }).toList();
  }

  Widget _weightsTable() {
    return DataCardColumn(
      children: dive.weightsystems.indexed.map((entry) {
        final idx = entry.$1;
        final ws = entry.$2;
        final desc = ws.description.isNotEmpty ? ws.description : 'Weight ${idx + 1}';
        return ColumnRow(label: desc, child: WeightText(ws.weight));
      }).toList(),
    );
  }

  Widget? _physioTable() {
    final worstDeco = dive.logs.isNotEmpty ? dive.logs.first.worstDecoStatus : null;
    final decoModel = dive.logs.isNotEmpty && dive.logs[0].hasDecoModel() ? dive.logs[0].decoModel : null;
    final children = <Widget>[];
    if (dive.hasMaxTemp() || dive.hasMinTemp()) children.add(_Temps(dive));
    if (dive.hasSac()) {
      children.add(
        ColumnRow(
          label: 'SAC',
          child: VolumeText(dive.sac, suffix: '/min'),
        ),
      );
    }
    if (dive.hasOtu()) children.add(ColumnRow(label: 'OTU', child: Text(dive.otu.toString())));
    if (dive.hasCns()) children.add(ColumnRow(label: 'CNS', child: Text('${dive.cns}%')));
    if (dive.hasEndSurfGf()) children.add(ColumnRow(label: 'SurfGF', child: Text('${dive.endSurfGf.round().clamp(0, 999)}%')));
    if (worstDeco != null) children.add(ColumnRow(label: 'Deco', child: DecoStatusText(worstDeco)));
    if (decoModel != null) children.add(ColumnRow(label: 'Model', child: DecoModelText(decoModel)));
    if (dive.logs.isNotEmpty && dive.logs.first.hasModel()) children.add(ColumnRow(label: 'Computer', child: Text(dive.logs.first.model)));
    if (dive.logs.isNotEmpty && dive.logs.first.hasSerial()) children.add(ColumnRow(label: 'Serial', child: Text(dive.logs.first.serial)));
    if (children.isEmpty) return null;
    return DataCardColumn(children: children);
  }

  Widget _depthsTable() {
    return DataCardColumn(
      children: [
        ColumnRow(label: 'Start', child: DateTimeText(dive.start.toDateTime())),
        ColumnRow(label: 'Duration', child: DurationText(dive.duration)),
        ColumnRow(label: 'Max depth', child: DepthText(dive.maxDepth)),
        ColumnRow(label: 'Mean depth', child: DepthText(dive.meanDepth)),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.dive, required this.site});

  final Dive dive;
  final Site? site;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(8.0),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 8,
        children: [
          Stack(
            children: [
              IgnorePointer(
                ignoring: platformIsMobile,
                child: _AspectMaxHeight(
                  aspectRatio: 2.5,
                  maxHeight: 250,
                  child: BlocBuilder<PreferencesBloc, PreferencesState>(
                    builder: (context, state) {
                      return DepthProfile(key: ValueKey((dive, state.preferences)), dive: dive, preferences: state.preferences);
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    context.pushNamed(AppRouteName.divesDetailsDepthProfile, pathParameters: {'diveID': dive.id});
                  },
                  tooltip: 'View fullscreen',
                ),
              ),
            ],
          ),
        ],
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
      return ColumnRow(
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
      return ColumnRow(label: 'Temp', child: TemperatureText(dive.maxTemp));
    }
    if (dive.hasMinTemp()) {
      return ColumnRow(label: 'Temp', child: TemperatureText(dive.minTemp));
    }
    return const SizedBox();
  }
}

class _SiteCard extends StatelessWidget {
  final Site site;

  const _SiteCard({required this.site});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: () {
          context.goNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': site.id});
        },
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const .all(16.0),
              child: Row(
                children: [
                  Expanded(child: Text(site.name, style: Theme.of(context).textTheme.titleMedium)),
                  Icon(Icons.chevron_right, size: 14, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
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
              padding: const .all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: .center,
                children: [
                  if (site.hasCountry()) LabeledChip(label: 'Country', child: Text(site.country)),
                  if (site.hasCountry()) LabeledChip(label: 'Location', child: Text(site.location)),
                  if (site.bodyOfWater.isNotEmpty) LabeledChip(label: 'Body of water', child: Text(site.bodyOfWater)),
                  if (site.hasPosition())
                    LabeledChip(label: 'Position', child: Text([formatLatitude(site.position.latitude), formatLongitude(site.position.longitude)].join(' '))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RawDiveDataScreen extends StatelessWidget {
  final Dive dive;

  const _RawDiveDataScreen({required this.dive});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const .all(16),
        child: SelectableText(
          JsonEncoder.withIndent('  ').convert(dive.toProto3Json()),
          style: Theme.of(context).textTheme.bodyMedium?.apply(fontFamily: 'Courier'),
        ),
      ),
    );
  }
}

class _CylinderColumn extends StatelessWidget {
  final int index;
  final String description;
  final int oxygenPct;
  final int heliumPct;
  final double volumeL;
  final double beginPressure;
  final double endPressure;
  final double sac;

  const _CylinderColumn({
    required this.index,
    required this.description,
    this.oxygenPct = 0,
    this.heliumPct = 0,
    this.volumeL = 0,
    this.beginPressure = 0,
    this.endPressure = 0,
    this.sac = 0,
  });

  @override
  Widget build(BuildContext context) {
    final desc = description.isNotEmpty ? description : 'Cylinder ${index + 1}';
    final details = <Widget>[ColumnRow(label: 'Cylinder', child: Text(desc))];
    details.add(ColumnRow(label: 'Mix', child: Text(formatGasPercentage(oxygenPct, heliumPct))));
    if (beginPressure > 0) details.add(ColumnRow(label: 'Start', child: PressureText(beginPressure)));
    if (endPressure > 0) details.add(ColumnRow(label: 'End', child: PressureText(endPressure)));
    if (beginPressure > 0 && endPressure > 0 && volumeL > 0) {
      details.add(ColumnRow(label: 'Volume used', child: VolumeText((beginPressure - endPressure) * volumeL)));
    }
    if (sac > 0) {
      details.add(
        ColumnRow(
          label: 'SAC',
          child: VolumeText(sac, suffix: '/min'),
        ),
      );
    }

    return DataCardColumn(children: details);
  }
}

class _MaybeCard extends StatelessWidget {
  const _MaybeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _WidthResponsive(
      narrow: child,
      wide: Card(
        child: Padding(padding: .all(16), child: child),
      ),
    );
  }
}

class _AspectMaxHeight extends StatelessWidget {
  const _AspectMaxHeight({required this.aspectRatio, required this.maxHeight, required this.child});

  final double aspectRatio;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth / aspectRatio;
        if (height > maxHeight) {
          return ConstrainedBox(constraints: .loose(.fromHeight(maxHeight)), child: child);
        }
        return AspectRatio(aspectRatio: aspectRatio, child: child);
      },
    );
  }
}

class _WidthResponsive extends StatelessWidget {
  const _WidthResponsive({required this.narrow, required this.wide});

  final Widget narrow;
  final Widget wide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layout) {
        if (layout.maxWidth < 600) return narrow;
        return wide;
      },
    );
  }
}
