import 'dart:convert';

import 'package:btcountries/btcountries.dart';
import 'package:btl10n/btl10n.dart';
import 'package:btproto/btproto.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide DataColumn;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:stretch_wrap/stretch_wrap.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../common/common.dart';
import '../equipment/cylinder_list_bloc.dart';
import '../equipment/equipment_list_bloc.dart';
import '../services/store/store.dart';
import 'depth_profile_widget.dart';
import 'dive_details_bloc.dart';
import 'dive_list_bloc.dart';
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
    return BlocConsumer<DiveDetailsBloc, DiveDetailsState>(
      listener: (context, state) {
        if (state is DiveDetailsClosed) {
          // Pop when the bloc considers us done
          context.pop();
        }
      },
      builder: (context, state) {
        return ScreenScaffold(
          title: Text(
            platformIsDesktop
                ? context.l10n.diveTitle(dive.number, site?.name ?? context.l10n.unknownSite)
                : context.l10n.compactDiveTitle(dive.number, site?.name ?? context.l10n.unknownSite),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: prevDive != null
                  ? () {
                      context.read<DiveDetailsBloc>().add(DiveDetailsEvent.loadDive(prevDive!.id));
                    }
                  : null,
              tooltip: prevDive != null ? context.l10n.diveNumber(prevDive!.number) : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: nextDive != null
                  ? () {
                      context.read<DiveDetailsBloc>().add(DiveDetailsEvent.loadDive(nextDive!.id));
                    }
                  : null,
              tooltip: nextDive != null ? context.l10n.diveNumber(nextDive!.number) : null,
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
    // The depths/times card is editable; the physio card is not.
    final depthsCard = _tappableDataCard(context, onTap: () => _editBasics(context), child: _depthsTable(context));
    final physioTable = _physioTable(context);
    final infoCards = <Widget>[
      depthsCard,
      if (physioTable != null)
        Card(
          child: Padding(padding: const .all(16.0), child: physioTable),
        ),
    ];

    // Cylinders (gases): one tappable card each, or an "add" affordance.
    final gasCards = dive.cylinders.isEmpty
        ? [_addDataCard(context, label: context.l10n.addGases, icon: Icons.gas_meter_outlined, onTap: () => _editGases(context))]
        : _cylindersTables().map<Widget>((t) => _tappableDataCard(context, onTap: () => _editGases(context), child: t)).toList();

    // Weights: a tappable card, or an "add" affordance.
    final weightCard = dive.weightsystems.isEmpty
        ? _addDataCard(context, label: context.l10n.addWeights, icon: Icons.fitness_center, onTap: () => _editWeights(context))
        : _tappableDataCard(context, onTap: () => _editWeights(context), child: _weightsTable(context));

    // Equipment: a tappable card, or an "add" affordance when none is set.
    final equipmentCard = dive.equipment.isEmpty
        ? _addDataCard(context, label: context.l10n.addEquipment, icon: Icons.inventory_2_outlined, onTap: () => _editEquipment(context))
        : _tappableDataCard(context, onTap: () => _editEquipment(context), child: _equipmentTable(context));

    final datacolumns =
        infoCards +
        gasCards +
        [
          weightCard,
          equipmentCard,
          if (site != null)
            ConstrainedBox(
              constraints: .loose(.fromWidth(600)),
              child: _SiteCard(site: site!, dive: dive),
            ),
        ];

    return [
      _MaybeCard(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            if (dive.logs.isNotEmpty && dive.logs[0].samples.isNotEmpty) _ProfileCard(dive: dive, site: site),
            _buddiesTagsEtc(context),
          ],
        ),
      ),
      _notesCard(context),
      StretchWrap(spacing: 8, runSpacing: 8, children: datacolumns.map((e) => Stretch(child: e)).toList()),
      if (platformIsMobile) Align(alignment: .centerRight, child: _popupMenuActions(context)),
    ];
  }

  // A dive that starts within this long of the previous one ending is offered
  // up for merging; a longer surface interval means it really was a new dive.
  static const _maxMergeGap = Duration(hours: 1);

  // The dive immediately before this one in time. Not necessarily the one the
  // navigation arrows reach, which follow the dive numbering.
  Dive? _precedingDive(BuildContext context) {
    final listState = context.read<DiveListBloc>().state;
    if (listState is! DiveListLoaded) return null;

    Dive? preceding;
    for (final d in listState.dives) {
      if (d.id == dive.id || d.start.seconds >= dive.start.seconds) continue;
      if (preceding == null || d.start.seconds > preceding.start.seconds) preceding = d;
    }
    return preceding;
  }

  bool _canMergeInto(Dive preceding) {
    final precedingEnd = preceding.start.toDateTime().add(Duration(seconds: preceding.duration));
    return dive.start.toDateTime().difference(precedingEnd) <= _maxMergeGap;
  }

  Future<void> _mergeIntoPrevious(BuildContext context, Dive preceding) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: context.l10n.mergeIntoPreviousDive,
      message: context.l10n.mergeDiveConfirmation(dive.number, preceding.number),
      confirmText: context.l10n.merge,
    );
    if (!confirmed || !context.mounted) return;

    context.read<DiveDetailsBloc>().add(DiveDetailsEvent.mergeIntoPrevious(preceding.id));
  }

  PopupMenuButton<String> _popupMenuActions(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'debug') {
          await showDialog(
            context: context,
            builder: (context) => _RawDiveDataScreen(dive: dive),
          );
        } else if (value == 'merge') {
          final preceding = _precedingDive(context);
          if (preceding != null) await _mergeIntoPrevious(context, preceding);
        } else if (value == 'delete') {
          final confirmed = await showConfirmationDialog(
            context: context,
            title: context.l10n.deleteDive,
            message: context.l10n.deleteDiveConfirmation(dive.number),
            confirmText: context.l10n.delete,
            isDestructive: true,
          );
          if (confirmed && context.mounted) {
            context.read<DiveDetailsBloc>().add(DiveDetailsEvent.deleteAndClose(dive.id));
          }
        }
      },
      itemBuilder: (context) {
        final preceding = _precedingDive(context);
        return [
          PopupMenuItem(value: 'debug', child: Text(context.l10n.viewRawData)),
          PopupMenuItem(value: 'merge', enabled: preceding != null && _canMergeInto(preceding), child: Text(context.l10n.mergeIntoPreviousDive)),
          PopupMenuItem(value: 'delete', child: Text(context.l10n.deleteDive)),
        ];
      },
    );
  }

  Wrap _buddiesTagsEtc(BuildContext context) {
    return Wrap(
      crossAxisAlignment: .center,
      runSpacing: 8,
      spacing: 24,
      children: [_siteSection(context), _buddiesSection(context), _tagsSection(context), _ratingSection(context), _divemasterSection(context)],
    );
  }

  // Dispatches a save of the current dive with [update] applied.
  void _save(BuildContext context, void Function(Dive) update) {
    context.read<DiveDetailsBloc>().add(DiveDetailsEvent.save(dive.rebuild(update)));
  }

  // Wraps [child] in a chip-sized tappable region, used for the editable
  // summary chips (site, buddies, tags, ...).
  Widget _tappableChip({required VoidCallback onTap, required Widget child}) {
    return InkWell(onTap: onTap, borderRadius: .circular(8), child: child);
  }

  // A tappable placeholder chip shown when a field is empty.
  Widget _addChip({required String label, required IconData icon, required VoidCallback onTap}) {
    return _tappableChip(
      onTap: onTap,
      child: Chip(avatar: Icon(icon, size: 18), label: Text(label), visualDensity: .compact, materialTapTargetSize: .shrinkWrap),
    );
  }

  Widget _siteSection(BuildContext context) {
    if (site == null) {
      return _addChip(label: context.l10n.addSite, icon: Icons.location_on_outlined, onTap: () => _editSite(context));
    }
    return _tappableChip(
      onTap: () => _editSite(context),
      child: LabeledChip(label: context.l10n.location, child: Text(site!.name)),
    );
  }

  Widget _buddiesSection(BuildContext context) {
    if (dive.buddies.isEmpty) {
      return _addChip(label: context.l10n.addBuddies, icon: Icons.group_outlined, onTap: () => _editBuddies(context));
    }
    return _tappableChip(
      onTap: () => _editBuddies(context),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: dive.buddies.map<Widget>((b) => LabeledChip(label: context.l10n.buddy, child: Text(b))).toList(),
      ),
    );
  }

  Widget _divemasterSection(BuildContext context) {
    if (dive.divemaster.isEmpty) {
      return _addChip(label: context.l10n.addDivemaster, icon: Icons.person_outline, onTap: () => _editDivemaster(context));
    }
    return _tappableChip(
      onTap: () => _editDivemaster(context),
      child: LabeledChip(label: context.l10n.divemaster, child: Text(dive.divemaster)),
    );
  }

  Future<void> _editSite(BuildContext context) async {
    final listState = context.read<DiveListBloc>().state;
    if (listState is! DiveListLoaded || listState.sites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.noDiveSitesAvailable)));
      return;
    }

    final res = await showSiteSelectionDialog(context: context, sites: listState.sites, selectedSite: site, noneOption: context.l10n.noSite);
    if (res.cancelled || !context.mounted) return;

    final newSiteId = res.value?.id ?? '';
    if (newSiteId == dive.siteId) return;

    _save(context, (d) => d.siteId = newSiteId);
  }

  Future<void> _editBuddies(BuildContext context) async {
    final listState = context.read<DiveListBloc>().state;
    final available = listState is DiveListLoaded ? listState.buddies : <String>{};
    final featured = listState is DiveListLoaded ? listState.activeBuddies : <String>{};

    final result = await showChipsEditor(
      context: context,
      title: context.l10n.buddies,
      addLabel: context.l10n.addBuddy,
      selectedValues: dive.buddies,
      availableValues: available,
      featuredValues: featured,
      textCapitalization: .words,
      createCharacters: const [','],
    );
    if (result == null || !context.mounted) return;
    if (SetEquality<String>().equals(result.toSet(), dive.buddies.toSet())) return;

    _save(context, (d) {
      d.buddies.clear();
      d.buddies.addAll(result);
    });
  }

  Future<void> _editDivemaster(BuildContext context) async {
    final result = await showTextEditor(
      context: context,
      title: context.l10n.divemaster,
      label: context.l10n.name,
      initialValue: dive.divemaster,
      textCapitalization: .words,
    );
    if (result == null || !context.mounted || result == dive.divemaster) return;

    _save(context, (d) => d.divemaster = result);
  }

  Widget _notesCard(BuildContext context) {
    final hasNotes = dive.notes.isNotEmpty;
    return Card(
      child: InkWell(
        onTap: () => _editNotes(context),
        borderRadius: .circular(12),
        child: Padding(
          padding: const .all(16.0),
          child: hasNotes
              ? Text(dive.notes)
              : Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.notes_outlined, size: 18, color: Theme.of(context).hintColor),
                    Text(context.l10n.addNotes, style: TextStyle(color: Theme.of(context).hintColor)),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _editNotes(BuildContext context) async {
    final result = await showTextEditor(context: context, title: context.l10n.notes, initialValue: dive.notes, maxLines: 6, textCapitalization: .sentences);
    if (result == null || !context.mounted || result == dive.notes) return;

    _save(context, (d) => d.notes = result);
  }

  // Wraps a data column in a tappable card, matching the non-editable cards.
  Widget _tappableDataCard(BuildContext context, {required VoidCallback onTap, required Widget child}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(12),
        child: Padding(padding: const .all(16.0), child: child),
      ),
    );
  }

  // An empty-state card inviting the user to add data.
  Widget _addDataCard(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(12),
        child: Padding(
          padding: const .all(16.0),
          child: Row(
            spacing: 8,
            children: [
              Icon(icon, size: 18, color: Theme.of(context).hintColor),
              Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editBasics(BuildContext context) async {
    // Depth and duration can only be edited when there's no real computer
    // profile; otherwise they're derived from the samples.
    final canEditDepthDuration = dive.logs.isEmpty || dive.logs.first.isSynthetic;

    final result = await showDiveBasicsEditor(
      context: context,
      number: dive.number,
      start: dive.start.toDateTime(),
      timezone: siteTimeZone(site),
      durationSeconds: dive.duration,
      maxDepth: dive.maxDepth,
      canEditDepthDuration: canEditDepthDuration,
    );
    if (result == null || !context.mounted) return;

    final numberChanged = result.number != dive.number;
    final startChanged = result.start != dive.start.toDateTime();
    final depthDurationChanged = canEditDepthDuration && (result.durationSeconds != dive.duration || result.maxDepth != dive.maxDepth);
    if (!numberChanged && !startChanged && !depthDurationChanged) return;

    _save(context, (d) {
      d.number = result.number;
      d.start = Timestamp.fromDateTime(result.start);
      if (canEditDepthDuration) {
        // Regenerate the synthetic profile from the new duration/depth.
        d.logs.clear();
        d.logs.add(syntheticLog(result.start, result.durationSeconds, result.maxDepth));
      }
      d.invalidateComputed();
    });
  }

  Future<void> _editEquipment(BuildContext context) async {
    final equipmentBloc = context.read<EquipmentListBloc>();
    final equipmentState = equipmentBloc.state;
    final visible = equipmentState is EquipmentListLoaded ? equipmentState.activeEquipment : <Equipment>[];
    // Include equipment already on the dive even if it's since been archived, so
    // it stays selectable and isn't silently dropped on save.
    final available = [...visible, ...dive.equipment.where((e) => !visible.any((v) => v.id == e.id))];

    final result = await showEquipmentSelectionDialog(
      context: context,
      allEquipment: available,
      selectedEquipment: dive.equipment.toList(),
      onSetAsDefault: (ids) => equipmentBloc.add(EquipmentListEvent.setDefaults(ids)),
    );
    if (result == null || !context.mounted) return;
    if (ListEquality<Equipment>().equals(result, dive.equipment.toList())) return;

    _save(context, (d) {
      d.equipment.clear();
      d.equipment.addAll(result);
    });
  }

  Future<void> _editWeights(BuildContext context) async {
    final result = await showWeightsEditor(context: context, weights: dive.weightsystems);
    if (result == null || !context.mounted) return;
    if (ListEquality<Weightsystem>().equals(result, dive.weightsystems.toList())) return;

    _save(context, (d) {
      d.weightsystems.clear();
      d.weightsystems.addAll(result);
    });
  }

  Future<void> _editGases(BuildContext context) async {
    final cylinderState = context.read<CylinderListBloc>().state;
    final available = cylinderState is CylinderListLoaded ? cylinderState.cylinders : <Cylinder>[];
    final existingGasChanges = dive.events.where((e) => e.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE).toList();

    final result = await showCylindersEditor(
      context: context,
      cylinders: dive.cylinders.toList(),
      availableCylinders: available,
      durationSeconds: dive.duration,
      gasChangeEvents: existingGasChanges,
    );
    if (result == null || !context.mounted) return;

    final cylindersChanged = !ListEquality<DiveCylinder>().equals(result.cylinders, dive.cylinders.toList());
    final gasChangesChanged = !ListEquality<SampleEvent>().equals(result.gasChangeEvents, existingGasChanges);
    if (!cylindersChanged && !gasChangesChanged) return;

    _save(context, (d) {
      d.cylinders.clear();
      d.cylinders.addAll(result.cylinders);

      // Replace the gas-change events, preserving any other event types.
      final others = d.events.where((e) => e.type != SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE).toList();
      d.events
        ..clear()
        ..addAll(others)
        ..addAll(result.gasChangeEvents);

      // Gas mix and switches affect the calculated metrics and deco, so recompute.
      d.invalidateComputed();
    });
  }

  Widget _tagsSection(BuildContext context) {
    final secondary = site?.tags.where((t) => !dive.tags.contains(t)).toList();
    return Row(
      mainAxisSize: .min,
      spacing: 6,
      children: [
        if (dive.tags.isEmpty) _addChip(label: context.l10n.addTags, icon: Icons.add, onTap: () => _editTags(context)),
        if (dive.tags.isNotEmpty)
          _tappableChip(
            onTap: () => _editTags(context),
            child: TagsList(tags: dive.tags, prefix: '#'),
          ),
        if (secondary?.isNotEmpty == true) TagsList(tags: [], secondaryTags: secondary, prefix: '#'),
      ],
    );
  }

  Future<void> _editTags(BuildContext context) async {
    final listState = context.read<DiveListBloc>().state;
    final availableTags = listState is DiveListLoaded ? listState.tags : <String>{};

    final result = await showTagsEditor(context: context, selectedTags: dive.tags, availableTags: availableTags);
    if (result == null || !context.mounted) return;

    // Only persist if the set of tags actually changed.
    if (SetEquality<String>().equals(result.toSet(), dive.tags.toSet())) return;

    _save(context, (d) {
      d.tags.clear();
      d.tags.addAll(result);
    });
  }

  Widget _ratingSection(BuildContext context) {
    if (dive.rating == 0) {
      return _addChip(label: context.l10n.addRating, icon: Icons.star_border, onTap: () => _editRating(context));
    }
    return _tappableChip(
      onTap: () => _editRating(context),
      child: Text('★' * dive.rating, style: const TextStyle(color: Colors.amber)),
    );
  }

  Future<void> _editRating(BuildContext context) async {
    final current = dive.hasRating() ? dive.rating : 0;
    final result = await showRatingEditor(context: context, rating: current);
    if (result == null || !context.mounted || result == current) return;

    _save(context, (d) {
      if (result == 0) {
        d.clearRating();
      } else {
        d.rating = result;
      }
    });
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

  Widget _weightsTable(BuildContext context) {
    return DataCardColumn(
      children: dive.weightsystems.indexed.map((entry) {
        final idx = entry.$1;
        final ws = entry.$2;
        final desc = ws.description.isNotEmpty ? ws.description : context.l10n.weightNumber(idx + 1);
        return ColumnRow(label: desc, child: WeightText(ws.weight));
      }).toList(),
    );
  }

  Widget _equipmentTable(BuildContext context) {
    final pc = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 8,
      runSpacing: platformIsDesktop ? 8 : 0,
      children: dive.equipment
          .map(
            (e) => Chip(
              avatar: EquipmentIcons.icon(EquipmentIcons.forType(e.type), color: pc),
              label: Text(EquipmentListTile.equipmentTitle(context, e)),
            ),
          )
          .toList(),
    );
  }

  Widget? _physioTable(BuildContext context) {
    final worstDeco = dive.logs.isNotEmpty ? dive.logs.first.worstDecoStatus : null;
    final decoModel = dive.logs.isNotEmpty && dive.logs[0].hasDecoModel() ? dive.logs[0].decoModel : null;
    final children = <Widget>[];
    if (dive.hasMaxTemp() || dive.hasMinTemp()) children.add(_Temps(dive));
    if (dive.hasSac()) {
      children.add(
        ColumnRow(
          label: context.l10n.sac,
          child: VolumeText(dive.sac, suffix: context.l10n.perMinute, precise: true),
        ),
      );
    }
    if (dive.hasOtu()) children.add(ColumnRow(label: context.l10n.otu, child: Text(dive.otu.toString())));
    if (dive.hasCns()) children.add(ColumnRow(label: context.l10n.cns, child: Text(context.l10n.percentage(dive.cns))));
    if (dive.hasEndSurfGf()) {
      children.add(ColumnRow(label: context.l10n.surfaceGradientFactor, child: Text(context.l10n.percentage(dive.endSurfGf.round().clamp(0, 999)))));
    }
    if (worstDeco != null) children.add(ColumnRow(label: context.l10n.decoLabel, child: DecoStatusText(worstDeco)));
    if (decoModel != null) children.add(ColumnRow(label: context.l10n.model, child: DecoModelText(decoModel)));
    if (dive.logs.isNotEmpty && dive.logs.first.hasModel()) children.add(ColumnRow(label: context.l10n.computer, child: Text(dive.logs.first.model)));
    if (dive.logs.isNotEmpty && dive.logs.first.hasSerial()) children.add(ColumnRow(label: context.l10n.serial, child: Text(dive.logs.first.serial)));
    if (children.isEmpty) return null;
    return DataCardColumn(children: children);
  }

  Widget _depthsTable(BuildContext context) {
    return DataCardColumn(
      children: [
        ColumnRow(label: context.l10n.number, child: Text('${dive.number}')),
        ColumnRow(
          label: context.l10n.start,
          child: DateTimeText(dive.start.toDateTime(), timezone: siteTimeZone(site)),
        ),
        ColumnRow(label: context.l10n.duration, child: DurationText(dive.duration)),
        ColumnRow(label: context.l10n.maxDepth, child: DepthText(dive.maxDepth)),
        ColumnRow(label: context.l10n.meanDepth, child: DepthText(dive.meanDepth)),
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
                  child: DepthProfile(key: ValueKey(dive), dive: dive),
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
                  tooltip: context.l10n.viewFullscreen,
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
    if (dive.hasMinTemp() && dive.hasMaxTemp() && dive.minTemp != dive.maxTemp) {
      return ColumnRow(
        label: context.l10n.temp,
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
      return ColumnRow(label: context.l10n.temp, child: TemperatureText(dive.maxTemp));
    }
    if (dive.hasMinTemp()) {
      return ColumnRow(label: context.l10n.temp, child: TemperatureText(dive.minTemp));
    }
    return const SizedBox();
  }
}

class _SiteCard extends StatelessWidget {
  final Site site;
  final Dive dive;

  const _SiteCard({required this.site, required this.dive});

  @override
  Widget build(BuildContext context) {
    LatLng? startPos;
    LatLng? endPos;
    if (dive.logs.firstOrNull?.hasStartPosition() == true) {
      final p = dive.logs.first.startPosition;
      startPos = LatLng(p.latitude, p.longitude);
    }
    if (dive.logs.firstOrNull?.hasEndPosition() == true) {
      final p = dive.logs.first.endPosition;
      endPos = LatLng(p.latitude, p.longitude);
    }
    LatLng? sitePos;
    if (site.hasPosition()) {
      final p = site.position;
      sitePos = LatLng(p.latitude, p.longitude);
    }
    final colorScheme = Theme.of(context).colorScheme;
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
            if (sitePos != null || startPos != null || endPos != null)
              InkWell(
                onTap: () {
                  context.pushNamed(
                    AppRouteName.sitesDetailsMap,
                    pathParameters: {'siteID': site.id},
                    extra: <String, LatLng?>{'startPosition': startPos, 'endPosition': endPos},
                  );
                },
                child: SizedBox(
                  height: 150,
                  child: IgnorePointer(
                    child: SiteMap(sitePosition: sitePos, startPosition: startPos, endPosition: endPos),
                  ),
                ),
              ),
            // Site information
            Padding(
              padding: const .all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: .center,
                children: [
                  if (site.hasCountry())
                    LabeledChip(
                      label: context.l10n.country,
                      child: Text(countryDisplayName(site.country, l10n: context.l10n)),
                    ),
                  if (site.hasCountry()) LabeledChip(label: context.l10n.location, child: Text(site.location)),
                  if (site.bodyOfWater.isNotEmpty) LabeledChip(label: context.l10n.bodyOfWater, child: Text(site.bodyOfWater)),
                  if (site.hasPosition())
                    LabeledChip(
                      label: context.l10n.sitePosition,
                      child: Text([formatLatitude(site.position.latitude), formatLongitude(site.position.longitude)].join(' ')),
                    ),
                  if (site.tags.isNotEmpty) TagsList(tags: site.tags, prefix: '#'),
                  if (dive.logs.isNotEmpty && dive.logs[0].hasStartPosition())
                    LabeledChip(
                      label: context.l10n.diveStartPosition,
                      backgroundColor: colorScheme.secondaryContainer,
                      child: Text([formatLatitude(dive.logs[0].startPosition.latitude), formatLongitude(dive.logs[0].startPosition.longitude)].join(' ')),
                    ),
                  if (dive.logs.isNotEmpty && dive.logs[0].hasEndPosition())
                    LabeledChip(
                      label: context.l10n.diveEndPosition,
                      backgroundColor: colorScheme.secondaryContainer,
                      child: Text([formatLatitude(dive.logs[0].endPosition.latitude), formatLongitude(dive.logs[0].endPosition.longitude)].join(' ')),
                    ),
                ],
              ),
            ),
            if (site.hasNotes()) Padding(padding: const .all(16), child: Text(site.notes)),
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
          JsonEncoder.withIndent('  ').convert(
            dive.rebuild((d) {
              final logs = d.logs.map((l) => l.rebuild((l) => l.clearRawData())).toList();
              d.logs.clear();
              d.logs.addAll(logs);
            }).toProto3Json(),
          ),
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
    final desc = description.isNotEmpty ? description : context.l10n.cylinderNumber(index + 1);
    final details = <Widget>[ColumnRow(label: context.l10n.cylinder, child: Text(desc))];
    details.add(ColumnRow(label: context.l10n.mix, child: Text(formatGasPercentage(context, oxygenPct, heliumPct))));
    if (beginPressure > 0) details.add(ColumnRow(label: context.l10n.start, child: PressureText(beginPressure)));
    if (endPressure > 0) details.add(ColumnRow(label: context.l10n.end, child: PressureText(endPressure)));
    if (beginPressure > 0 && endPressure > 0 && volumeL > 0) {
      details.add(ColumnRow(label: context.l10n.volumeUsed, child: VolumeText((beginPressure - endPressure) * volumeL)));
    }
    if (sac > 0) {
      details.add(
        ColumnRow(
          label: context.l10n.sac,
          child: VolumeText(sac, suffix: context.l10n.perMinute, precise: true),
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
