import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ssrf/ssrf.dart' as ssrf;
import '../ssrf/storage/storage.dart';

abstract class CylinderDetailsState extends Equatable {
  const CylinderDetailsState();

  @override
  List<Object?> get props => [];
}

class CylinderDetailsInitial extends CylinderDetailsState {
  const CylinderDetailsInitial();
}

class CylinderDetailsLoading extends CylinderDetailsState {
  const CylinderDetailsLoading();
}

class CylinderDetailsLoaded extends CylinderDetailsState {
  final ssrf.Cylinder cylinder;
  final bool isNew;

  const CylinderDetailsLoaded(this.cylinder, this.isNew);

  @override
  List<Object?> get props => [cylinder, isNew];
}

class CylinderDetailsError extends CylinderDetailsState {
  final String message;

  const CylinderDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class CylinderDetailsEvent extends Equatable {
  const CylinderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCylinderDetails extends CylinderDetailsEvent {
  final int cylinderId;

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
  final ssrf.Cylinder cylinder;

  const UpdateCylinderDetails(this.cylinder);

  @override
  List<Object?> get props => [cylinder];
}

class CylinderDetailsBloc extends Bloc<CylinderDetailsEvent, CylinderDetailsState> {
  final SsrfStorage _storage;

  CylinderDetailsBloc({SsrfStorage? storage}) : _storage = storage ?? SsrfStorage(), super(const CylinderDetailsInitial()) {
    on<LoadCylinderDetails>(_onLoadCylinderDetails);
    on<UpdateCylinderDetails>(_onUpdateCylinderDetails);
    on<NewCylinderEvent>(_onNewCylinder);
  }

  Future<void> _onLoadCylinderDetails(LoadCylinderDetails event, Emitter<CylinderDetailsState> emit) async {
    try {
      final cylinder = await _storage.cylinders.getById(event.cylinderId);
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
        final id = await _storage.cylinders.insert(event.cylinder);
        add(LoadCylinderDetails(id));
      } else {
        await _storage.cylinders.update(event.cylinder);
        add(LoadCylinderDetails(event.cylinder.id));
      }
    } catch (e) {
      emit(CylinderDetailsError('Failed to update cylinder: $e'));
    }
  }

  Future<void> _onNewCylinder(NewCylinderEvent event, Emitter<CylinderDetailsState> emit) async {
    const cylinder = ssrf.Cylinder(id: 0);
    emit(const CylinderDetailsLoaded(cylinder, true));
  }
}
