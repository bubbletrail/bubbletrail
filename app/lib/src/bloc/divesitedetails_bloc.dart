import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'details_state.dart';

abstract class DivesiteDetailsState extends Equatable with DetailsStateMixin {
  const DivesiteDetailsState();

  @override
  List<Object?> get props => [];
}

class DivesiteDetailsInitial extends DivesiteDetailsState with DetailsInitialMixin {
  const DivesiteDetailsInitial();
}

class DivesiteDetailsLoading extends DivesiteDetailsState with DetailsLoadingMixin {
  const DivesiteDetailsLoading();
}

class DivesiteDetailsLoaded extends DivesiteDetailsState with DetailsLoadedMixin {
  final Divesite divesite;
  final bool isNew;

  const DivesiteDetailsLoaded(this.divesite, this.isNew);

  @override
  List<Object?> get props => [divesite, isNew];
}

class DivesiteDetailsError extends DivesiteDetailsState with DetailsErrorMixin {
  @override
  final String errorMessage;

  const DivesiteDetailsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

abstract class DivesiteDetailsEvent extends Equatable {
  const DivesiteDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDivesiteDetails extends DivesiteDetailsEvent {
  final String siteId;

  const LoadDivesiteDetails(this.siteId);

  @override
  List<Object?> get props => [siteId];
}

class NewDivesiteEvent extends DivesiteDetailsEvent {
  const NewDivesiteEvent();

  @override
  List<Object?> get props => [];
}

class UpdateDivesiteDetails extends DivesiteDetailsEvent {
  final Divesite divesite;

  const UpdateDivesiteDetails(this.divesite);

  @override
  List<Object?> get props => [divesite];
}

class DivesiteDetailsBloc extends Bloc<DivesiteDetailsEvent, DivesiteDetailsState> {
  final SsrfStorage _storage;

  DivesiteDetailsBloc({SsrfStorage? storage}) : _storage = storage ?? SsrfStorage(), super(const DivesiteDetailsInitial()) {
    on<LoadDivesiteDetails>(_onLoadDivesiteDetails);
    on<UpdateDivesiteDetails>(_onUpdateDivesiteDetails);
    on<NewDivesiteEvent>(_onNewDivesite);
  }

  Future<void> _onLoadDivesiteDetails(LoadDivesiteDetails event, Emitter<DivesiteDetailsState> emit) async {
    try {
      final divesite = await _storage.divesites.getById(event.siteId);
      if (divesite == null) {
        emit(const DivesiteDetailsError('Dive site not found'));
        return;
      }

      emit(DivesiteDetailsLoaded(divesite, false));
    } catch (e) {
      emit(DivesiteDetailsError('Failed to load dive site details: $e'));
    }
  }

  Future<void> _onUpdateDivesiteDetails(UpdateDivesiteDetails event, Emitter<DivesiteDetailsState> emit) async {
    try {
      final s = state as DivesiteDetailsLoaded;
      if (s.isNew) {
        await _storage.divesites.insert(event.divesite);
      } else {
        await _storage.divesites.update(event.divesite);
      }
      add(LoadDivesiteDetails(event.divesite.uuid));
    } catch (e) {
      emit(DivesiteDetailsError('Failed to update dive site: $e'));
    }
  }

  Future<void> _onNewDivesite(NewDivesiteEvent event, Emitter<DivesiteDetailsState> emit) async {
    final divesite = Divesite(uuid: const Uuid().v4(), name: '');
    emit(DivesiteDetailsLoaded(divesite, true));
  }
}
