import 'dart:async';
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btbuhlmann/btbuhlmann.dart' as buhlmann;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../providers/storage_provider.dart';
import 'tissue_calculator.dart';

part 'dive_list_bloc.g.dart';

final _log = Logger('divelist_bloc.dart');

abstract class DiveListState extends Equatable {
  const DiveListState();

  @override
  List<Object?> get props => [];
}

class DiveListInitial extends DiveListState {
  const DiveListInitial();
}

class DiveListLoading extends DiveListState {
  const DiveListLoading();
}

@CopyWith(copyWithNull: true)
class DiveListLoaded extends DiveListState {
  final List<Dive> dives;
  final List<Site> sites;
  final Set<String> tags;
  final Set<String> buddies;

  /// Index map for O(1) dive lookup by ID
  late final Map<String, Dive> divesById;

  /// Index map for O(1) dive list index lookup by ID
  late final Map<String, int> diveIndexById;

  /// Index map for O(1) dive site lookup by UUID
  late final Map<String, Site> sitesByUuid;

  /// Index map for O(1) dive count lookup by site UUID
  late final Map<String, int> diveCountBySiteId;

  DiveListLoaded(this.dives, this.sites, this.tags, this.buddies) {
    divesById = {for (final d in dives) d.id: d};
    diveIndexById = {for (var i = 0; i < dives.length; i++) dives[i].id: i};
    sitesByUuid = {for (final s in sites) s.id: s};
    // Build dive count map
    diveCountBySiteId = {};
    for (final d in dives) {
      if (d.hasSiteId()) {
        diveCountBySiteId[d.siteId] = (diveCountBySiteId[d.siteId] ?? 0) + 1;
      }
    }
  }

  @override
  List<Object?> get props => [dives, sites, tags, buddies];
}

sealed class DiveListEvent extends Equatable {
  const DiveListEvent();

  @override
  List<Object?> get props => [];

  const factory DiveListEvent.importDives(String filePath) = _ImportDives;
}

class _LoadAll extends DiveListEvent {
  const _LoadAll();
}

class _ImportDives extends DiveListEvent {
  final String filePath;

  const _ImportDives(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class DiveListBloc extends Bloc<DiveListEvent, DiveListState> {
  late final Store _store;
  StreamSubscription? _divesStorageSub;
  StreamSubscription? _sitesStorageSub;

  DiveListBloc() : super(const DiveListInitial()) {
    on<DiveListEvent>((event, emit) async {
      switch (event) {
        case _LoadAll():
          await _onLoadDives(emit);
        case _ImportDives():
          await _onImportDives(event, emit);
      }
    }, transformer: sequential());

    StorageProvider.store.then((value) {
      _store = value;
      _divesStorageSub = _store.dives.changes.listen((event) {
        add(_LoadAll());
      });
      _sitesStorageSub = _store.sites.changes.listen((event) {
        add(_LoadAll());
      });
      add(_LoadAll());
    });
  }

  Future<void> _onLoadDives(Emitter<DiveListState> emit) async {
    var dives = await _store.dives.getAll();
    final sites = await _store.sites.getAll();

    // Calculate tissues for dives that are missing them
    dives = await _calculateMissingTissues(dives);

    final currentState = state;
    if (currentState is DiveListLoaded) {
      emit(currentState.copyWith(dives: dives, sites: sites, tags: _store.tags, buddies: _store.dives.buddies));
    } else {
      emit(DiveListLoaded(dives, sites, _store.tags, _store.dives.buddies));
    }
  }

  /// Calculate and persist tissues for any dives that are missing them.
  Future<List<Dive>> _calculateMissingTissues(List<Dive> dives) async {
    // Sort all dives chronologically for tissue chaining
    final chronological = List<Dive>.from(dives);
    chronological.sort((a, b) => a.start.seconds.compareTo(b.start.seconds));

    // Track which dives need updating
    final updatedDives = <String, Dive>{};
    DateTime? prevDiveEnd;
    Tissues? prevEndTissues;

    for (final dive in chronological) {
      final diveStart = dive.start.toDateTime();
      final diveEnd = diveStart.add(Duration(seconds: dive.duration));
      var startTissues = dive.hasStartTissues() && dive.startTissues.generation == buhlmann.generation ? dive.startTissues : null;
      var startChanged = false;

      var cfg = buhlmann.BuhlmannConfig();
      if (dive.logs.firstOrNull?.hasAtmosphericPressure() == true) {
        cfg = buhlmann.BuhlmannConfig(surfacePressure: dive.logs.first.atmosphericPressure);
      }

      // Calculate start tissues from previous dive
      if (prevDiveEnd == null || diveStart.difference(prevDiveEnd) > tissueResetDuration) {
        startTissues = null; // Start with clean tissues
      } else if (prevEndTissues != null && startTissues != null && startTissues.chainId.isNotEmpty && startTissues.chainId == prevEndTissues.chainId) {
        // We have an unbroken chain, start tissues are already calculated
      } else if (prevEndTissues != null) {
        // Simulate surface interval off-gassing
        _log.fine('calculate start tissues for dive ${dive.id}');
        final surfaceInterval = diveStart.difference(prevDiveEnd).inSeconds.toDouble();
        if (surfaceInterval > 0) {
          final deco = buhlmann.BuhlmannDeco(config: cfg, tissues: protoToTissueState(prevEndTissues));
          deco.addSegment(0, buhlmann.GasMix.air, surfaceInterval);
          startTissues = tissueStateToProto(deco.tissues, diveStart, prevEndTissues.chainId);
        } else {
          startTissues = prevEndTissues;
        }
        startChanged = true;
      }

      // If we're missing end tissues or the chain has changed, recalculate
      if (!dive.hasEndTissues() ||
          !dive.hasEndSurfGf() ||
          dive.endTissues.chainId.isEmpty ||
          dive.endTissues.generation != buhlmann.generation ||
          startChanged) {
        // Load full dive data with samples
        _log.fine('calculate end tissues for dive ${dive.id}');
        final fullDive = await _store.diveById(dive.id);
        if (fullDive != null && fullDive.logs.isNotEmpty) {
          final (endTissues, surfGF) = calculateDiveTissues(config: cfg, dive: fullDive, startTissues: protoToTissueState(startTissues));
          final updatedDive = fullDive.rebuild((d) {
            if (startTissues != null) {
              d.startTissues = startTissues;
            } else {
              d.clearStartTissues();
            }
            d.endTissues = tissueStateToProto(endTissues, diveEnd, Uuid().v4().toString());
            d.endSurfGf = surfGF;
          });
          await _store.dives.update(updatedDive);
          updatedDives[dive.id] = updatedDive.rebuild((d) => d.logs.clear()); // Clear logs for list view
          prevEndTissues = updatedDive.endTissues;
        }
      } else {
        // Use existing tissues for next dive
        prevEndTissues = dive.endTissues;
      }

      prevDiveEnd = diveEnd;
    }

    // Return updated dive list
    if (updatedDives.isEmpty) return dives;
    return dives.map((d) => updatedDives[d.id] ?? d).toList();
  }

  Future<void> _onImportDives(_ImportDives event, Emitter<DiveListState> emit) async {
    final currentState = state as DiveListLoaded;
    emit(DiveListLoading());

    // Read the import file
    final importedDoc = await compute((path) async {
      final xmlData = await File(path).readAsString();
      final doc = XmlDocument.parse(xmlData);
      return importXml(doc);
    }, event.filePath);

    // Merge dive sites: only add new ones (check by uuid)
    final existingSiteUuids = currentState.sites.map((s) => s.id).toSet();
    final newSites = importedDoc.sites.where((s) => !existingSiteUuids.contains(s.id)).toList();
    await _store.sites.updateAll(newSites);

    // Load default cylinders for assignment
    final defaultBackgas = await _store.cylinders.getDefaultForBackgas();
    final defaultDeepDeco = await _store.cylinders.getDefaultForDeepDeco();
    final defaultShallowDeco = await _store.cylinders.getDefaultForShallowDeco();

    for (final dive in importedDoc.dives) {
      // Process cylinders
      for (final cyl in dive.cylinders) {
        if (cyl.hasCylinder()) {
          final c = cyl.cylinder;
          final cr = await _store.cylinders.getOrCreate(
            c.hasVolumeL() ? c.volumeL : null,
            c.hasWorkingPressureBar() ? c.workingPressureBar : null,
            c.hasDescription() ? c.description : null,
          );
          cyl.cylinderId = cr.id;
        }

        // If still no cylinder assigned, apply default based on O2 content
        if (cyl.cylinderId.isEmpty) {
          final o2Percent = cyl.oxygen * 100;
          if (o2Percent > 60 && defaultShallowDeco != null) {
            cyl.cylinderId = defaultShallowDeco.id;
          } else if (o2Percent >= 40 && defaultDeepDeco != null) {
            cyl.cylinderId = defaultDeepDeco.id;
          } else if (defaultBackgas != null) {
            cyl.cylinderId = defaultBackgas.id;
          }
        }
      }

      // Process equipment
      for (final (idx, eq) in dive.equipment.indexed) {
        final matched = await _store.equipment.getOrCreate(
          type: eq.type,
          manufacturer: eq.manufacturer,
          name: eq.name,
          serial: eq.serial,
          weight: eq.hasWeight() ? eq.weight : null,
          purchaseDate: eq.hasPurchaseDate() ? eq.purchaseDate : null,
          purchasePrice: eq.hasPurchasePrice() ? eq.purchasePrice : null,
          shop: eq.hasShop() ? eq.shop : null,
          warrantyUntil: eq.hasWarrantyUntil() ? eq.warrantyUntil : null,
          lastService: eq.hasLastService() ? eq.lastService : null,
        );
        dive.equipment[idx] = Equipment(id: matched.id);
      }

      dive.recalculateMetadata();
    }

    // Insert all imported dives
    await _store.dives.insertAll(importedDoc.dives);

    // Reload overview list after update
    add(_LoadAll());
  }

  @override
  Future<void> close() {
    _divesStorageSub?.cancel();
    _sitesStorageSub?.cancel();
    return super.close();
  }
}
