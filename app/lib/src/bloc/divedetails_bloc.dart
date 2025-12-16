import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ssrf/ssrf.dart' as ssrf;
import '../ssrf/storage/storage.dart';
import '../ssrf/types.dart';

abstract class DiveDetailsState extends Equatable {
  const DiveDetailsState();

  @override
  List<Object?> get props => [];
}

class DiveDetailsInitial extends DiveDetailsState {
  const DiveDetailsInitial();
}

class DiveDetailsLoading extends DiveDetailsState {
  const DiveDetailsLoading();
}

class DiveDetailsLoaded extends DiveDetailsState {
  final ssrf.Dive dive;
  final ssrf.Divesite? diveSite;

  const DiveDetailsLoaded(this.dive, this.diveSite);

  @override
  List<Object?> get props => [dive, diveSite];
}

class DiveDetailsError extends DiveDetailsState {
  final String message;

  const DiveDetailsError(this.message);

  @override
  List<Object?> get props => [message];
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
  final ssrf.Dive dive;

  const UpdateDiveDetails(this.dive);

  @override
  List<Object?> get props => [dive];
}

class DiveDetailsBloc extends Bloc<DiveDetailsEvent, DiveDetailsState> {
  final SsrfStorage _storage;
  final void Function()? onDiveUpdated;

  DiveDetailsBloc({SsrfStorage? storage, this.onDiveUpdated}) : _storage = storage ?? SsrfStorage(), super(const DiveDetailsInitial()) {
    on<LoadDiveDetails>(_onLoadDiveDetails);
    on<UpdateDiveDetails>(_onUpdateDiveDetails);
    on<NewDiveEvent>(_onNewDive);
  }

  Future<void> _onLoadDiveDetails(LoadDiveDetails event, Emitter<DiveDetailsState> emit) async {
    try {
      // Load full dive data with all children
      final dive = await _storage.dives.getById(event.diveId);
      if (dive == null) {
        emit(const DiveDetailsError('Dive not found'));
        return;
      }

      // Load dive site if available
      ssrf.Divesite? diveSite;
      if (dive.divesiteid != null) {
        diveSite = await _storage.divesites.getById(dive.divesiteid!);
      }

      emit(DiveDetailsLoaded(dive, diveSite));
    } catch (e) {
      emit(DiveDetailsError('Failed to load dive details: $e'));
    }
  }

  Future<void> _onUpdateDiveDetails(UpdateDiveDetails event, Emitter<DiveDetailsState> emit) async {
    try {
      await _storage.dives.update(event.dive);
      add(LoadDiveDetails(event.dive.id));
      onDiveUpdated?.call();
    } catch (e) {
      emit(DiveDetailsError('Failed to update dive: $e'));
    }
  }

  Future<void> _onNewDive(NewDiveEvent event, Emitter<DiveDetailsState> emit) async {
    final dive = Dive(number: 0, start: DateTime.now(), duration: 0);
    emit(DiveDetailsLoaded(dive, null));
  }
}
