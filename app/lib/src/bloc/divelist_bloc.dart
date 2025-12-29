import 'dart:io';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:xml/xml.dart';

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

class DiveListLoaded extends DiveListState {
  final List<Dive> dives;
  final List<Site> sites;
  final Log? lastLog;

  /// Index map for O(1) dive lookup by ID
  late final Map<String, Dive> divesById;

  /// Index map for O(1) dive list index lookup by ID
  late final Map<String, int> diveIndexById;

  /// Index map for O(1) dive site lookup by UUID
  late final Map<String, Site> sitesByUuid;

  /// Index map for O(1) dive count lookup by site UUID
  late final Map<String, int> diveCountBySiteId;

  DiveListLoaded(this.dives, this.sites, this.lastLog) {
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
  List<Object?> get props => [dives, sites];
}

class DiveListError extends DiveListState {
  final String message;

  const DiveListError(this.message);

  @override
  List<Object?> get props => [message];
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

class DiveListBloc extends Bloc<DiveListEvent, DiveListState> {
  final Store _storage = Store();

  DiveListBloc() : super(const DiveListInitial()) {
    on<DiveListEvent>((event, emit) async {
      if (event is LoadDives) {
        await _onLoadDives(event, emit);
      } else if (event is UpdateDive) {
        await _onUpdateDive(event, emit);
      } else if (event is ImportDives) {
        await _onImportDives(event, emit);
      } else if (event is DownloadedDives) {
        await _onDownloadedDives(event, emit);
      }
    }, transformer: sequential());

    // Automatically load dives when the bloc is created
    add(const LoadDives());
  }

  Future<void> _onLoadDives(LoadDives event, Emitter<DiveListState> emit) async {
    try {
      final dives = await _storage.dives.getAll();
      final sites = await _storage.sites.getAll();
      Log? lastLog;
      if (dives.isNotEmpty) {
        lastLog = (await _storage.dives.getById(dives.first.id))?.logs.firstOrNull;
      }
      emit(DiveListLoaded(dives, sites, lastLog));
    } catch (e) {
      emit(DiveListError('Failed to load dives: $e'));
    }
  }

  Future<void> _onUpdateDive(UpdateDive event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;

    final currentState = state as DiveListLoaded;

    try {
      // Is it a new dive? If so, set the dive number and insert it.
      if (event.dive.number <= 0) {
        event.dive.number = currentState.dives.isEmpty ? 1 : currentState.dives.map((d) => d.number).reduce(max) + 1;
        await _storage.dives.insert(event.dive);
        _log.info('Inserted new dive #${event.dive.number}');
      } else {
        // Update existing dive
        await _storage.dives.update(event.dive);
        _log.fine('Updated dive #${event.dive.number}');
      }

      // Reload overview list after update
      add(LoadDives());
    } catch (e) {
      emit(DiveListError('Failed to update dive: $e'));
    }
  }

  Future<void> _onImportDives(ImportDives event, Emitter<DiveListState> emit) async {
    try {
      // Read the SSRF file
      final xmlData = await File(event.filePath).readAsString();
      final doc = XmlDocument.parse(xmlData);
      final importedSsrf = SsrfXml.fromXml(doc.rootElement);

      final currentState = state as DiveListLoaded;

      // Merge dive sites: only add new ones (check by uuid)
      final existingSiteUuids = currentState.sites.map((s) => s.id).toSet();
      final newSites = importedSsrf.sites.where((s) => !existingSiteUuids.contains(s.id)).toList();
      await _storage.sites.insertAll(newSites);

      // Process cylinders
      for (final dive in importedSsrf.dives) {
        for (final cyl in dive.cylinders) {
          if (cyl.hasCylinder()) {
            final c = cyl.cylinder;
            final cr = await _storage.cylinders.getOrCreate(
              c.hasSize() ? c.size : null,
              c.hasWorkpressure() ? c.workpressure : null,
              c.hasDescription() ? c.description : null,
            );
            cyl.cylinderId = cr.id;
            cyl.clearCylinder();
          }
        }
      }

      // Insert all imported dives
      await _storage.dives.insertAll(importedSsrf.dives);

      // Reload overview list after update
      add(LoadDives());
    } catch (e) {
      emit(DiveListError('Failed to import dives: $e'));
    }
  }

  Future<void> _onDownloadedDives(DownloadedDives event, Emitter<DiveListState> emit) async {
    try {
      // Sort dives by time, number them, insert.
      final downloaded = event.dives;
      downloaded.sort((a, b) => a.start.seconds.compareTo(b.start.seconds));
      var nextID = await _storage.dives.nextDiveNo;
      for (final d in downloaded) {
        d.number = nextID;
        nextID++;
      }
      await _storage.dives.insertAll(downloaded);

      // Reload overview list after update
      add(LoadDives());
    } catch (e) {
      emit(DiveListError('Failed to import dives: $e'));
    }
  }
}
