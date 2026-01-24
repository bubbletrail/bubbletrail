import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import '../common/details_state.dart';
import '../providers/storage_provider.dart';

part 'dive_details_bloc.g.dart';

final _log = Logger('dive_details_bloc.dart');

abstract class DiveDetailsState extends Equatable with DetailsStateMixin {
  const DiveDetailsState();

  @override
  List<Object?> get props => [];
}

class DiveDetailsInitial extends DiveDetailsState {
  const DiveDetailsInitial();
}

@CopyWith()
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
  const factory DiveDetailsEvent.close() = _Close;
  const factory DiveDetailsEvent.saveAndClose(Dive dive) = _SaveAndClose;
  const factory DiveDetailsEvent.deleteAndClose(String diveID) = _DeleteAndClose;
}

class _NewDive extends DiveDetailsEvent {
  const _NewDive();
}

class _LoadDive extends DiveDetailsEvent {
  final String diveId;

  const _LoadDive(this.diveId);
}

class _Close extends DiveDetailsEvent {
  const _Close();
}

class _SaveAndClose extends DiveDetailsEvent {
  final Dive dive;

  const _SaveAndClose(this.dive);
}

class _DeleteAndClose extends DiveDetailsEvent {
  final String diveID;

  const _DeleteAndClose(this.diveID);
}

class DiveDetailsBloc extends Bloc<DiveDetailsEvent, DiveDetailsState> {
  StreamSubscription? _storageSubscription;

  DiveDetailsBloc() : super(const DiveDetailsInitial()) {
    _log.fine('init');
    on<DiveDetailsEvent>((event, emit) async {
      switch (event) {
        case _NewDive():
          final s = await StorageProvider.store;
          final n = await s.dives.nextDiveNo;
          final t = Timestamp.fromDateTime(DateTime.now());
          emit(DiveDetailsLoaded(Dive(number: n, start: t)..freeze()));
        case _LoadDive():
          await _onLoadDive(event, emit);
        case _Close():
          emit(DiveDetailsClosed());
        case _SaveAndClose():
          final s = await StorageProvider.store;
          await s.dives.update(event.dive);
          _log.fine('saved dive #${event.dive.number}');
          emit(DiveDetailsClosed());
        case _DeleteAndClose():
          final s = await StorageProvider.store;
          await s.dives.delete(event.diveID);
          _log.fine('deleted dive ${event.diveID}');
          emit(DiveDetailsClosed());
      }
    }, transformer: sequential());
  }

  Future<void> _onLoadDive(_LoadDive event, Emitter<DiveDetailsState> emit) async {
    final s = await StorageProvider.store;
    final dive = await s.diveById(event.diveId);
    if (dive == null) {
      emit(DiveDetailsClosed());
      return;
    }

    _storageSubscription ??= s.dives.changes.listen((_) {
      // Reload the dive when storage changes. Use the dive ID from the
      // current state, because the dive we track may have changed since the
      // bloc was created.
      final s = state;
      if (s is! DiveDetailsLoaded) return;
      add(_LoadDive(s.dive.id));
    });

    _log.fine('loaded dive #${dive.number} (${dive.id})');

    Dive? nextDive;
    Dive? prevDive;
    final allDives = await s.dives.getAll();
    final curIdx = allDives.indexWhere((d) => d.id == event.diveId);
    if (curIdx > 0) prevDive = allDives[curIdx - 1];
    if (curIdx < allDives.length - 1) nextDive = allDives[curIdx + 1];

    Site? site;
    if (dive.siteId.isNotEmpty) {
      site = await s.sites.getById(dive.siteId);
    }
    if (site != null) {
      _log.fine('loaded site ${site.name}');
    }
    emit(DiveDetailsLoaded(dive, site: site, nextDive: nextDive, prevDive: prevDive));
  }

  @override
  Future<void> close() {
    _log.fine('close');
    _storageSubscription?.cancel();
    return super.close();
  }
}
