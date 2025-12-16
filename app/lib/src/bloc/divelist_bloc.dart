import 'dart:io';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xml/xml.dart';

import '../ssrf/ssrf.dart' as ssrf;
import '../ssrf/storage/storage.dart';

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
  final List<ssrf.Dive> dives;
  final List<ssrf.Divesite> diveSites;

  const DiveListLoaded(this.dives, this.diveSites);

  @override
  List<Object?> get props => [dives, diveSites];
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
  final ssrf.Dive dive;

  const UpdateDive(this.dive);

  @override
  List<Object?> get props => [dive];
}

class ImportDives extends DiveListEvent {
  final String filePath;

  const ImportDives(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class DiveListBloc extends Bloc<DiveListEvent, DiveListState> {
  final SsrfStorage _storage = SsrfStorage();

  DiveListBloc() : super(const DiveListInitial()) {
    on<DiveListEvent>((event, emit) async {
      if (event is LoadDives) {
        await _onLoadDives(event, emit);
      } else if (event is UpdateDive) {
        await _onUpdateDive(event, emit);
      } else if (event is ImportDives) {
        await _onImportDives(event, emit);
      }
    }, transformer: sequential());

    // Automatically load dives when the bloc is created
    add(const LoadDives());
  }

  Future<void> _onLoadDives(LoadDives event, Emitter<DiveListState> emit) async {
    emit(const DiveListLoading());

    try {
      // Load only overview data (from dives table) for efficiency
      final dives = await _storage.dives.getAllOverview();
      final diveSites = await _storage.divesites.getAll();
      emit(DiveListLoaded(dives, diveSites));
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
      } else {
        // Update existing dive
        await _storage.dives.update(event.dive);
      }

      // Reload overview list after update
      final dives = await _storage.dives.getAllOverview();
      emit(DiveListLoaded(dives, currentState.diveSites));
    } catch (e) {
      emit(DiveListError('Failed to update dive: $e'));
    }
  }

  Future<void> _onImportDives(ImportDives event, Emitter<DiveListState> emit) async {
    try {
      // Read the SSRF file
      final xmlData = await File(event.filePath).readAsString();
      final doc = XmlDocument.parse(xmlData);
      final importedSsrf = ssrf.SsrfXml.fromXml(doc.rootElement);

      if (state is DiveListLoaded) {
        final currentState = state as DiveListLoaded;

        // Merge dive sites: only add new ones (check by uuid)
        final existingSiteUuids = currentState.diveSites.map((s) => s.uuid).toSet();
        final newSites = importedSsrf.diveSites.where((s) => !existingSiteUuids.contains(s.uuid)).toList();
        await _storage.divesites.insertAll(newSites);

        // Insert all imported dives
        await _storage.dives.insertAll(importedSsrf.dives);
      } else {
        await _storage.saveAll(importedSsrf);
      }

      // Reload overview list after import
      final dives = await _storage.dives.getAllOverview();
      final diveSites = await _storage.divesites.getAll();
      emit(DiveListLoaded(dives, diveSites));
    } catch (e) {
      emit(DiveListError('Failed to import dives: $e'));
    }
  }

  @override
  Future<void> close() {
    _storage.close();
    return super.close();
  }
}
