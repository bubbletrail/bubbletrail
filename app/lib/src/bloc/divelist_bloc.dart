import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

import 'sync_bloc.dart';

part 'divelist_bloc.g.dart';

final _log = Logger('DiveListBloc');

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
  final Log? lastLog;
  final Set<String> tags;
  final Set<String> buddies;

  /// Selected dive (full data with samples) for details/edit screens
  final Dive? selectedDive;

  /// Site for the selected dive
  final Site? selectedDiveSite;

  /// Whether the selected dive is new (not yet saved)
  final bool isNewDive;

  /// Selected site for edit screen
  final Site? selectedSite;

  /// Whether the selected site is new (not yet saved)
  final bool isNewSite;

  /// Index map for O(1) dive lookup by ID
  late final Map<String, Dive> divesById;

  /// Index map for O(1) dive list index lookup by ID
  late final Map<String, int> diveIndexById;

  /// Index map for O(1) dive site lookup by UUID
  late final Map<String, Site> sitesByUuid;

  /// Index map for O(1) dive count lookup by site UUID
  late final Map<String, int> diveCountBySiteId;

  DiveListLoaded(
    this.dives,
    this.sites,
    this.lastLog,
    this.tags,
    this.buddies, {
    this.selectedDive,
    this.selectedDiveSite,
    this.isNewDive = false,
    this.selectedSite,
    this.isNewSite = false,
  }) {
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
  List<Object?> get props => [dives, sites, tags, buddies, selectedDive, selectedDiveSite, isNewDive, selectedSite, isNewSite];
}

abstract class DiveListEvent extends Equatable {
  const DiveListEvent();

  @override
  List<Object?> get props => [];
}

class LoadDives extends DiveListEvent {
  const LoadDives();
}

class UpdateDive extends DiveListEvent {
  final Dive dive;

  const UpdateDive(this.dive);

  @override
  List<Object?> get props => [dive];
}

class DownloadedDives extends DiveListEvent {
  final List<Dive> dives;

  const DownloadedDives(this.dives);

  @override
  List<Object?> get props => [dives];
}

class ImportDives extends DiveListEvent {
  final String filePath;

  const ImportDives(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class SelectDive extends DiveListEvent {
  final String diveId;

  const SelectDive(this.diveId);

  @override
  List<Object?> get props => [diveId];
}

class SelectNewDive extends DiveListEvent {
  const SelectNewDive();
}

class SelectSite extends DiveListEvent {
  final String siteId;

  const SelectSite(this.siteId);

  @override
  List<Object?> get props => [siteId];
}

class SelectNewSite extends DiveListEvent {
  const SelectNewSite();
}

class UpdateSite extends DiveListEvent {
  final Site site;

  const UpdateSite(this.site);

  @override
  List<Object?> get props => [site];
}

class DeleteDive extends DiveListEvent {
  final String diveId;

  const DeleteDive(this.diveId);

  @override
  List<Object?> get props => [diveId];
}

class DiveListBloc extends Bloc<DiveListEvent, DiveListState> {
  final SyncBloc _syncBloc;
  late final Store _store;
  StreamSubscription? _syncBlocSub;

  DiveListBloc(this._syncBloc) : super(const DiveListInitial()) {
    on<DiveListEvent>((event, emit) async {
      if (event is LoadDives) {
        await _onLoadDives(event, emit);
      } else if (event is UpdateDive) {
        await _onUpdateDive(event, emit);
      } else if (event is ImportDives) {
        await _onImportDives(event, emit);
      } else if (event is DownloadedDives) {
        await _onDownloadedDives(event, emit);
      } else if (event is SelectDive) {
        await _onSelectDive(event, emit);
      } else if (event is SelectNewDive) {
        await _onSelectNewDive(event, emit);
      } else if (event is SelectSite) {
        await _onSelectSite(event, emit);
      } else if (event is SelectNewSite) {
        await _onSelectNewSite(event, emit);
      } else if (event is UpdateSite) {
        await _onUpdateSite(event, emit);
      } else if (event is DeleteDive) {
        await _onDeleteDive(event, emit);
      }
    }, transformer: sequential());

    _syncBloc.store.then((value) {
      _store = value;
      add(LoadDives());
    });

    _syncBlocSub = _syncBloc.stream.listen((state) {
      add(LoadDives());
    });
  }

  Future<void> _onLoadDives(LoadDives event, Emitter<DiveListState> emit) async {
    final dives = await _store.dives.getAll();
    final sites = await _store.sites.getAll();
    Log? lastLog;
    if (dives.isNotEmpty) {
      lastLog = (await _store.dives.getById(dives.first.id))?.logs.firstOrNull;
      if (lastLog != null) {
        lastLog = lastLog.rebuild((lastLog) {
          lastLog.samples.clear();
        });
      }
    }
    final currentState = state;
    if (currentState is DiveListLoaded) {
      emit(currentState.copyWith(dives: dives, sites: sites, lastLog: lastLog, tags: _store.tags, buddies: _store.dives.buddies));
    } else {
      emit(DiveListLoaded(dives, sites, lastLog, _store.tags, _store.dives.buddies));
    }
  }

  Future<void> _onUpdateDive(UpdateDive event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;

    final currentState = state as DiveListLoaded;

    // Is it a new dive? If so, set the dive number and insert it.
    if (event.dive.number <= 0) {
      event.dive.number = currentState.dives.isEmpty ? 1 : currentState.dives.map((d) => d.number).reduce(max) + 1;
      await _store.dives.insert(event.dive);
      _log.info('Inserted new dive #${event.dive.number}');
    } else {
      // Update existing dive
      await _store.dives.update(event.dive);
      _log.fine('Updated dive #${event.dive.number}');
    }

    // Reload overview list after update
    add(LoadDives());
  }

  Future<void> _onImportDives(ImportDives event, Emitter<DiveListState> emit) async {
    // Read the import file
    final xmlData = await File(event.filePath).readAsString();
    final doc = XmlDocument.parse(xmlData);
    final importedSsrf = importXml(doc);

    final currentState = state as DiveListLoaded;

    // Merge dive sites: only add new ones (check by uuid)
    final existingSiteUuids = currentState.sites.map((s) => s.id).toSet();
    final newSites = importedSsrf.sites.where((s) => !existingSiteUuids.contains(s.id)).toList();
    await _store.sites.insertAll(newSites);

    // Process cylinders
    for (final dive in importedSsrf.dives) {
      for (final cyl in dive.cylinders) {
        if (cyl.hasCylinder()) {
          final c = cyl.cylinder;
          final cr = await _store.cylinders.getOrCreate(
            c.hasSize() ? c.size : null,
            c.hasWorkpressure() ? c.workpressure : null,
            c.hasDescription() ? c.description : null,
          );
          cyl.cylinderId = cr.id;
        }
      }
      dive.recalculateMedata();
    }

    // Insert all imported dives
    await _store.dives.insertAll(importedSsrf.dives);

    // Reload overview list after update
    add(LoadDives());
  }

  Future<void> _onDownloadedDives(DownloadedDives event, Emitter<DiveListState> emit) async {
    // Sort dives by time; number them; insert.

    final downloaded = event.dives;
    downloaded.sort((a, b) => a.start.seconds.compareTo(b.start.seconds));

    var nextID = await _store.dives.nextDiveNo;
    for (final d in downloaded) {
      d.number = nextID;
      nextID++;
    }

    await _store.dives.insertAll(downloaded);

    // Reload overview list after update
    add(LoadDives());
  }

  Future<void> _onSelectDive(SelectDive event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;
    final currentState = state as DiveListLoaded;

    final dive = await _store.diveById(event.diveId);
    if (dive == null) {
      _log.warning('Dive ${event.diveId} not found');
      return;
    }

    Site? site;
    if (dive.hasSiteId()) {
      site = await _store.sites.getById(dive.siteId);
    }

    emit(currentState.copyWith(selectedDive: dive, selectedDiveSite: site, isNewDive: false));
  }

  Future<void> _onSelectNewDive(SelectNewDive event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;
    final currentState = state as DiveListLoaded;

    final diveNo = await _store.dives.nextDiveNo;
    final dive = Dive(number: diveNo, start: Timestamp.fromDateTime(DateTime.now()), duration: 0);

    emit(currentState.copyWith(selectedDive: dive, isNewDive: true).copyWithNull(selectedDiveSite: true));
  }

  Future<void> _onSelectSite(SelectSite event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;
    final currentState = state as DiveListLoaded;

    final site = await _store.sites.getById(event.siteId);
    if (site == null) {
      _log.warning('Site ${event.siteId} not found');
      return;
    }

    emit(currentState.copyWith(selectedSite: site, isNewSite: false));
  }

  Future<void> _onSelectNewSite(SelectNewSite event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;
    final currentState = state as DiveListLoaded;

    final site = Site(id: const Uuid().v4(), name: '');

    emit(currentState.copyWith(selectedSite: site, isNewSite: true));
  }

  Future<void> _onUpdateSite(UpdateSite event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;
    final currentState = state as DiveListLoaded;

    if (currentState.isNewSite) {
      await _store.sites.insert(event.site);
      _log.info('Inserted new site ${event.site.name}');
    } else {
      await _store.sites.update(event.site);
      _log.fine('Updated site ${event.site.name}');
    }

    // Reload list after update
    add(LoadDives());
  }

  Future<void> _onDeleteDive(DeleteDive event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;

    await _store.dives.delete(event.diveId);
    _log.info('Deleted dive ${event.diveId}');

    // Reload list after delete
    add(LoadDives());
  }

  @override
  Future<void> close() {
    _syncBlocSub?.cancel();
    return super.close();
  }
}
