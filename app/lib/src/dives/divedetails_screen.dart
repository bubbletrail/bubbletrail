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
                title: 'Delete dive',
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
            const PopupMenuItem(value: 'debug', child: Text('View raw data')),
            const PopupMenuItem(value: 'delete', child: Text('Delete dive')),
          ],
        ),
      ],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: _buildAllSections(context)),
        ),
      ),
    );
  }

  List<Widget> _buildAllSections(BuildContext context) {
    final datacolumns =
        (<Widget?>[_depthsTable(), _physioTable()] + _cylindersTables() + [if (dive.weightsystems.isNotEmpty) _weightsTable()])
            .where((w) => w != null)
            .map<Widget>(
              (t) => Card(
                child: Padding(padding: const EdgeInsets.all(16.0), child: t),
              ),
            )
            .toList() +
        [
          if (site != null)
            ConstrainedBox(
              constraints: BoxConstraints.loose(Size.fromWidth(600)),
              child: _SiteCard(site: site!),
            ),
        ];

    return [
      _MaybeCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dive.logs.isNotEmpty && dive.logs[0].samples.isNotEmpty) _ProfileCard(dive: dive, site: site),
            _buddiesTagsEtc(),
          ],
        ),
      ),
      if (dive.notes.isNotEmpty)
        Card(
          child: Padding(padding: const EdgeInsets.all(16.0), child: Text(dive.notes)),
        ),
      _WidthResponsive(
        narrow: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: datacolumns),
        wide: Wrap(alignment: WrapAlignment.start, crossAxisAlignment: WrapCrossAlignment.start, spacing: 8, runSpacing: 8, children: datacolumns),
      ),
    ];
  }

  Wrap _buddiesTagsEtc() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
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
    return _DataColumn(
      children: dive.weightsystems.indexed.map((entry) {
        final idx = entry.$1;
        final ws = entry.$2;
        final desc = ws.description.isNotEmpty ? ws.description : 'Weight ${idx + 1}';
        return _ColumnRow(label: desc, child: WeightText(ws.weight));
      }).toList(),
    );
  }

  Widget? _physioTable() {
    final worstDeco = dive.logs.isNotEmpty ? dive.logs.first.worstDecoStatus : null;
    final decoModel = dive.logs.isNotEmpty && dive.logs[0].hasDecoModel() ? dive.logs[0].decoModel : null;
    final childen = <Widget>[];
    if (dive.hasMaxTemp() || dive.hasMinTemp()) childen.add(_Temps(dive));
    if (dive.hasSac()) {
      childen.add(
        _ColumnRow(
          label: 'SAC',
          child: VolumeText(dive.sac, suffix: '/min'),
        ),
      );
    }
    if (dive.hasOtu()) childen.add(_ColumnRow(label: 'OTU', child: Text(dive.otu.toString())));
    if (dive.hasCns()) childen.add(_ColumnRow(label: 'CNS', child: Text('${dive.cns}%')));
    if (worstDeco != null) childen.add(_ColumnRow(label: 'Deco', child: DecoStatusText(worstDeco)));
    if (decoModel != null) childen.add(_ColumnRow(label: 'Model', child: DecoModelText(decoModel)));
    if (childen.isEmpty) return null;
    return _DataColumn(children: childen);
  }

  Widget _depthsTable() {
    return _DataColumn(
      children: [
        _ColumnRow(label: 'Start', child: DateTimeText(dive.start.toDateTime())),
        _ColumnRow(label: 'Duration', child: DurationText(dive.duration)),
        _ColumnRow(label: 'Max depth', child: DepthText(dive.maxDepth)),
        _ColumnRow(label: 'Mean depth', child: DepthText(dive.meanDepth)),
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Stack(
            children: [
              IgnorePointer(
                ignoring: Platform.isIOS,
                child: _AspectMaxHeight(
                  aspectRatio: 2.5,
                  maxHeight: 250,
                  child: BlocBuilder<PreferencesBloc, PreferencesState>(
                    builder: (context, state) {
                      return DepthProfileWidget(
                        key: ValueKey((dive, state.preferences)),
                        log: dive.logs[0],
                        preferences: state.preferences,
                        cylinders: dive.cylinders,
                        events: dive.events,
                      );
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
      return _ColumnRow(
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
      return _ColumnRow(label: 'Temp', child: TemperatureText(dive.maxTemp));
    }
    if (dive.hasMinTemp()) {
      return _ColumnRow(label: 'Temp', child: TemperatureText(dive.minTemp));
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': site.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: Text(site.name, style: Theme.of(context).textTheme.titleMedium)),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.primary),
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
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
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
        padding: const EdgeInsets.all(16),
        child: SelectableText(dive.toTextFormat(), style: Theme.of(context).textTheme.bodyMedium?.apply(fontFamily: 'Courier')),
      ),
    );
  }
}

class _DataColumn extends StatelessWidget {
  const _DataColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(child: Column(children: children));
  }
}

class _ColumnRow extends StatelessWidget {
  const _ColumnRow({required this.label, required this.child});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(opacity: 0.5, child: Text(label ?? '', style: Theme.of(context).textTheme.labelSmall)),
        SizedBox(width: 16),
        child,
      ],
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
    final details = <Widget>[_ColumnRow(label: 'Cylinder', child: Text(desc))];
    details.add(_ColumnRow(label: 'Mix', child: Text(formatGasPercentage(oxygenPct, heliumPct))));
    if (beginPressure > 0) details.add(_ColumnRow(label: 'Start', child: PressureText(beginPressure)));
    if (endPressure > 0) details.add(_ColumnRow(label: 'End', child: PressureText(endPressure)));
    if (beginPressure > 0 && endPressure > 0 && volumeL > 0) {
      details.add(_ColumnRow(label: 'Volume used', child: VolumeText((beginPressure - endPressure) * volumeL)));
    }
    if (sac > 0) {
      details.add(
        _ColumnRow(
          label: 'SAC',
          child: VolumeText(sac, suffix: '/min'),
        ),
      );
    }

    return _DataColumn(children: details);
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
        child: Padding(padding: EdgeInsetsGeometry.all(16), child: child),
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
          return ConstrainedBox(constraints: BoxConstraints.loose(Size.fromHeight(maxHeight)), child: child);
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
