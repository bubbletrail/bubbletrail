import 'dart:ui';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btproto/btproto.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../common/details_state.dart';
import '../providers/storage_provider.dart';
import '../services/store/store.dart';

final _log = Logger('dive_details_bloc.dart');

abstract class DiveDetailsState extends Equatable with DetailsStateMixin {
  const DiveDetailsState();

  @override
  List<Object?> get props => [];
}

class DiveDetailsInitial extends DiveDetailsState {
  const DiveDetailsInitial();
}

class DiveDetailsLoaded extends DiveDetailsState {
  final Dive dive;
  final Site? site;
  final Dive? nextDive;
  final Dive? prevDive;

  const DiveDetailsLoaded(this.dive, {this.site, this.nextDive, this.prevDive});

  @override
  bool get isLoaded => true;

  @override
  List<Object?> get props => [dive, site, nextDive, prevDive];
}

class DiveDetailsClosed extends DiveDetailsState {
  const DiveDetailsClosed();

  @override
  List<Object?> get props => [];
}

sealed class DiveDetailsEvent extends Equatable {
  const DiveDetailsEvent();

  @override
  List<Object?> get props => [];

  const factory DiveDetailsEvent.newDive() = _NewDive;
  const factory DiveDetailsEvent.loadDive(String diveId) = _LoadDive;
  const factory DiveDetailsEvent.save(Dive dive) = _Save;
  const factory DiveDetailsEvent.deleteAndClose(String diveID) = _DeleteAndClose;
  const factory DiveDetailsEvent.mergeIntoPrevious(String previousDiveID) = _MergeIntoPrevious;
}

class _NewDive extends DiveDetailsEvent {
  const _NewDive();
}

class _LoadDive extends DiveDetailsEvent {
  final String diveId;

  const _LoadDive(this.diveId);
}

class _Save extends DiveDetailsEvent {
  final Dive dive;

  const _Save(this.dive);
}

class _DeleteAndClose extends DiveDetailsEvent {
  final String diveID;

  const _DeleteAndClose(this.diveID);
}

class _MergeIntoPrevious extends DiveDetailsEvent {
  final String previousDiveID;

  const _MergeIntoPrevious(this.previousDiveID);

  @override
  List<Object?> get props => [previousDiveID];
}

class DiveDetailsBloc extends Bloc<DiveDetailsEvent, DiveDetailsState> {
  final _store = StorageProvider.instance.store;
  VoidCallback? _storageListener;

  DiveDetailsBloc() : super(const DiveDetailsInitial()) {
    _log.fine('init');
    on<DiveDetailsEvent>((event, emit) async {
      switch (event) {
        case _NewDive():
          final n = await _store.dives.nextDiveNo;
          final t = Timestamp.fromDateTime(DateTime.now());
          final defaultEquipment = await _store.equipment.getDefaultsForNewDives();
          // Give the dive a stable id up front so inline edits can save it, but
          // don't persist until the first edit — an untouched new dive that's
          // navigated away from leaves nothing behind.
          emit(DiveDetailsLoaded(Dive(id: Uuid().v7(), number: n, start: t, equipment: defaultEquipment)..freeze()));
        case _LoadDive():
          await _onLoadDive(event, emit);
        case _Save():
          // Persist without closing, then reload so the view updates in place
          // (and the storage listener is registered for a first-time save of a
          // newly created dive).
          await _store.dives.update(event.dive);
          _log.fine('saved dive #${event.dive.number}');
          await _onLoadDive(_LoadDive(event.dive.id), emit);
        case _DeleteAndClose():
          await _store.dives.delete(event.diveID);
          _log.fine('deleted dive ${event.diveID}');
          emit(DiveDetailsClosed());
        case _MergeIntoPrevious():
          await _onMergeIntoPrevious(event, emit);
      }
    }, transformer: sequential());
  }

  // Fold the currently shown dive into the one before it: the profile and
  // events move over, the current dive is deleted, and everything derived from
  // the samples is recomputed. Leaves the previous dive on screen.
  Future<void> _onMergeIntoPrevious(_MergeIntoPrevious event, Emitter<DiveDetailsState> emit) async {
    final s = state;
    if (s is! DiveDetailsLoaded) return;

    final current = await _store.diveById(s.dive.id);
    final previous = await _store.diveById(event.previousDiveID);
    if (current == null || previous == null) {
      _log.warning('cannot merge dive ${s.dive.id} into ${event.previousDiveID}: dive not found');
      return;
    }

    final merged = previous.rebuild((d) {
      d.appendDive(current);
      d.invalidateComputed();
    });
    await _store.dives.update(merged);
    await _store.dives.delete(current.id);
    _log.info('merged dive #${current.number} into #${merged.number}');

    await _onLoadDive(_LoadDive(merged.id), emit);
  }

  Future<void> _onLoadDive(_LoadDive event, Emitter<DiveDetailsState> emit) async {
    final dive = await _store.diveById(event.diveId);
    if (dive == null || dive.meta.isDeleted) {
      // Only give up if the dive that went away is the one we're showing. A
      // storage change can queue a reload for a dive we've since navigated
      // away from (merging does exactly that), and that shouldn't close us.
      final s = state;
      if (s is! DiveDetailsLoaded || s.dive.id == event.diveId) emit(DiveDetailsClosed());
      return;
    }

    if (_storageListener == null) {
      _storageListener = () {
        // Reload the dive when storage changes. Use the dive ID from the
        // current state, because the dive we track may have changed since the
        // bloc was created.
        final s = state;
        if (s is! DiveDetailsLoaded) return;
        add(_LoadDive(s.dive.id));
      };
      _store.dives.addListener(_storageListener!);
    }

    _log.fine('loaded dive #${dive.number} (${dive.id})');

    Dive? nextDive;
    Dive? prevDive;
    final allDives = await _store.dives.getAll();
    final curIdx = allDives.indexWhere((d) => d.id == event.diveId);
    if (curIdx > 0) prevDive = allDives[curIdx - 1];
    if (curIdx < allDives.length - 1) nextDive = allDives[curIdx + 1];

    Site? site;
    if (dive.siteId.isNotEmpty) {
      site = await _store.sites.getById(dive.siteId);
    }
    if (site != null) {
      _log.fine('loaded site ${site.name}');
    }
    emit(DiveDetailsLoaded(dive, site: site, nextDive: nextDive, prevDive: prevDive));
  }

  @override
  Future<void> close() {
    _log.fine('close');
    if (_storageListener != null) {
      _store.dives.removeListener(_storageListener!);
    }
    return super.close();
  }
}
