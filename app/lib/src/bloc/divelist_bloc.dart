import 'dart:io';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import '../ssrf/ssrf.dart';

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
  final List<Divesite> diveSites;

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

class SaveDives extends DiveListEvent {
  const SaveDives();
}

class UpdateDive extends DiveListEvent {
  final Dive dive;

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
  DiveListBloc() : super(const DiveListInitial()) {
    on<LoadDives>(_onLoadDives);
    on<SaveDives>(_onSaveDives);
    on<UpdateDive>(_onUpdateDive);
    on<ImportDives>(_onImportDives);

    // Automatically load dives when the bloc is created
    add(const LoadDives());
  }

  Future<void> _onLoadDives(LoadDives event, Emitter<DiveListState> emit) async {
    emit(const DiveListLoading());

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final xmlData = await File('${docsDir.path}/dives.ssrf').readAsString();
      final doc = XmlDocument.parse(xmlData);
      final ssrf = Ssrf.fromXml(doc.rootElement);

      emit(DiveListLoaded(ssrf.dives, ssrf.diveSites));
      add(const SaveDives());
    } catch (e) {
      emit(DiveListError('Failed to load dives: $e'));
    }
  }

  Future<void> _onSaveDives(SaveDives event, Emitter<DiveListState> emit) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final ds = (state as DiveListLoaded);
      final doc = Ssrf(dives: ds.dives, diveSites: ds.diveSites);
      final docXml = doc.toXmlDocument().toXmlString(pretty: true);
      await File('${docsDir.path}/dives.ssrf.new').writeAsString(docXml);
      await File('${docsDir.path}/dives.ssrf.new').rename('${docsDir.path}/dives.ssrf');
    } catch (e) {
      emit(DiveListError('Failed to save dives: $e'));
    }
  }

  Future<void> _onUpdateDive(UpdateDive event, Emitter<DiveListState> emit) async {
    if (state is! DiveListLoaded) return;

    final currentState = state as DiveListLoaded;

    // Is it a new dive? If so, set the dive number and add it to the list.
    if (event.dive.number <= 0) {
      event.dive.number = currentState.dives.map((d) => d.number).reduce(max) + 1;
      emit(DiveListLoaded(currentState.dives + [event.dive], currentState.diveSites));
      add(const SaveDives());
      return;
    }

    // Find the dive in the list and update it
    final diveIndex = currentState.dives.indexWhere((d) => d == event.dive);
    if (diveIndex != -1) {
      final updatedDives = List<Dive>.from(currentState.dives);
      updatedDives[diveIndex] = event.dive;
      emit(DiveListLoaded(updatedDives, currentState.diveSites));
      add(const SaveDives());
    }
  }

  Future<void> _onImportDives(ImportDives event, Emitter<DiveListState> emit) async {
    try {
      // Read the SSRF file
      final xmlData = await File(event.filePath).readAsString();
      final doc = XmlDocument.parse(xmlData);
      final importedSsrf = Ssrf.fromXml(doc.rootElement);
      print("loading ${importedSsrf.dives.length} dives");
      if (state is DiveListLoaded) {
        final currentState = state as DiveListLoaded;

        // Merge dives: add imported dives to existing ones
        final allDives = List<Dive>.from(currentState.dives);
        allDives.addAll(importedSsrf.dives);

        // Merge dive sites: only add new ones (check by uuid)
        final existingSiteUuids = currentState.diveSites.map((s) => s.uuid).toSet();
        final newSites = importedSsrf.diveSites.where((s) => !existingSiteUuids.contains(s.uuid)).toList();
        final allDiveSites = List<Divesite>.from(currentState.diveSites);
        allDiveSites.addAll(newSites);

        emit(DiveListLoaded(allDives, allDiveSites));
      } else {
        emit(DiveListLoaded(importedSsrf.dives, importedSsrf.diveSites));
      }
      add(const SaveDives());
    } catch (e) {
      emit(DiveListError('Failed to import dives: $e'));
    }
  }
}
