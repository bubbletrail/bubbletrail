import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'details_state.dart';

abstract class CylinderDetailsState extends Equatable with DetailsStateMixin {
  const CylinderDetailsState();

  @override
  List<Object?> get props => [];
}

class CylinderDetailsInitial extends CylinderDetailsState with DetailsInitialMixin {
  const CylinderDetailsInitial();
}

class CylinderDetailsLoading extends CylinderDetailsState with DetailsLoadingMixin {
  const CylinderDetailsLoading();
}

class CylinderDetailsLoaded extends CylinderDetailsState with DetailsLoadedMixin {
  final Cylinder cylinder;
  final bool isNew;

  const CylinderDetailsLoaded(this.cylinder, this.isNew);

  @override
  List<Object?> get props => [cylinder, isNew];
}

class CylinderDetailsError extends CylinderDetailsState with DetailsErrorMixin {
  @override
  final String errorMessage;

  const CylinderDetailsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

abstract class CylinderDetailsEvent extends Equatable {
  const CylinderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCylinderDetails extends CylinderDetailsEvent {
  final String cylinderId;

  const LoadCylinderDetails(this.cylinderId);

  @override
  List<Object?> get props => [cylinderId];
}

class NewCylinderEvent extends CylinderDetailsEvent {
  const NewCylinderEvent();

  @override
  List<Object?> get props => [];
}

class UpdateCylinderDetails extends CylinderDetailsEvent {
  final Cylinder cylinder;

  const UpdateCylinderDetails(this.cylinder);

  @override
  List<Object?> get props => [cylinder];
}

class CylinderDetailsBloc extends Bloc<CylinderDetailsEvent, CylinderDetailsState> {
  final Store _store = Store();

  CylinderDetailsBloc() : super(const CylinderDetailsInitial()) {
    on<LoadCylinderDetails>(_onLoadCylinderDetails);
    on<UpdateCylinderDetails>(_onUpdateCylinderDetails);
    on<NewCylinderEvent>(_onNewCylinder);
  }

  Future<void> _onLoadCylinderDetails(LoadCylinderDetails event, Emitter<CylinderDetailsState> emit) async {
    try {
      final cylinder = await _store.cylinders.getById(event.cylinderId);
      if (cylinder == null) {
        emit(const CylinderDetailsError('Cylinder not found'));
        return;
      }

      emit(CylinderDetailsLoaded(cylinder, false));
    } catch (e) {
      emit(CylinderDetailsError('Failed to load cylinder details: $e'));
    }
  }

  Future<void> _onUpdateCylinderDetails(UpdateCylinderDetails event, Emitter<CylinderDetailsState> emit) async {
    try {
      final s = state as CylinderDetailsLoaded;
      if (s.isNew) {
        final id = await _store.cylinders.insert(event.cylinder);
        add(LoadCylinderDetails(id));
      } else {
        await _store.cylinders.update(event.cylinder);
        add(LoadCylinderDetails(event.cylinder.id));
      }
    } catch (e) {
      emit(CylinderDetailsError('Failed to update cylinder: $e'));
    }
  }

  Future<void> _onNewCylinder(NewCylinderEvent event, Emitter<CylinderDetailsState> emit) async {
    emit(CylinderDetailsLoaded(Cylinder(), true));
  }
}
