import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'details_state.dart';
import 'sync_bloc.dart';

abstract class DiveDetailsState extends Equatable with DetailsStateMixin {
  const DiveDetailsState();

  @override
  List<Object?> get props => [];
}

class DiveDetailsInitial extends DiveDetailsState with DetailsInitialMixin {
  const DiveDetailsInitial();
}

class DiveDetailsLoading extends DiveDetailsState with DetailsLoadingMixin {
  const DiveDetailsLoading();
}

class DiveDetailsLoaded extends DiveDetailsState with DetailsLoadedMixin {
  final Dive dive;
  final Site? site;
  final bool newDive;

  const DiveDetailsLoaded(this.dive, this.site, this.newDive);

  @override
  List<Object?> get props => [dive, site, newDive];
}

class DiveDetailsError extends DiveDetailsState with DetailsErrorMixin {
  @override
  final String errorMessage;

  const DiveDetailsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

abstract class DiveDetailsEvent extends Equatable {
  const DiveDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDiveDetails extends DiveDetailsEvent {
  final String diveId;

  const LoadDiveDetails(this.diveId);

  @override
  List<Object?> get props => [diveId];
}

class NewDiveEvent extends DiveDetailsEvent {
  const NewDiveEvent();

  @override
  List<Object?> get props => [];
}

class UpdateDiveDetails extends DiveDetailsEvent {
  final Dive dive;

  const UpdateDiveDetails(this.dive);

  @override
  List<Object?> get props => [dive];
}

class DiveDetailsBloc extends Bloc<DiveDetailsEvent, DiveDetailsState> {
  final SyncBloc _syncBloc;

  DiveDetailsBloc(this._syncBloc) : super(const DiveDetailsInitial()) {
    on<LoadDiveDetails>(_onLoadDiveDetails);
    on<UpdateDiveDetails>(_onUpdateDiveDetails);
    on<NewDiveEvent>(_onNewDive);
  }

  Future<void> _onLoadDiveDetails(LoadDiveDetails event, Emitter<DiveDetailsState> emit) async {
    try {
      final store = await _syncBloc.store;
      // Load full dive data with all children
      final dive = await store.dives.getById(event.diveId);
      if (dive == null) {
        emit(const DiveDetailsError('Dive not found'));
        return;
      }

      // Load dive site if available
      Site? site;
      if (dive.hasSiteId()) {
        site = await store.sites.getById(dive.siteId);
      }

      emit(DiveDetailsLoaded(dive, site, false));
    } catch (e) {
      emit(DiveDetailsError('Failed to load dive details: $e'));
    }
  }

  Future<void> _onUpdateDiveDetails(UpdateDiveDetails event, Emitter<DiveDetailsState> emit) async {
    try {
      final details = state as DiveDetailsLoaded;
      final store = await _syncBloc.store;
      if (details.newDive) {
        await store.dives.insert(event.dive);
      } else {
        await store.dives.update(event.dive);
      }
      add(LoadDiveDetails(event.dive.id));
    } catch (e) {
      emit(DiveDetailsError('Failed to update dive: $e'));
    }
  }

  Future<void> _onNewDive(NewDiveEvent event, Emitter<DiveDetailsState> emit) async {
    final store = await _syncBloc.store;
    final diveNo = await store.dives.nextDiveNo;
    final dive = Dive(number: diveNo, start: Timestamp.fromDateTime(DateTime.now()), duration: 0);
    emit(DiveDetailsLoaded(dive, null, true));
  }
}
