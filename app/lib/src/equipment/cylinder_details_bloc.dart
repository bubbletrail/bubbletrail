import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/details_state.dart';
import '../providers/storage_provider.dart';

final _log = Logger('cylinderdetails_bloc.dart');

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

sealed class CylinderDetailsEvent extends Equatable {
  const CylinderDetailsEvent();

  @override
  List<Object?> get props => [];

  const factory CylinderDetailsEvent.load(String cylinderId) = _LoadCylinderDetails;
  const factory CylinderDetailsEvent.newCylinder() = _NewCylinder;
  const factory CylinderDetailsEvent.update(Cylinder cylinder) = _UpdateCylinderDetails;
}

class _LoadCylinderDetails extends CylinderDetailsEvent {
  final String cylinderId;

  const _LoadCylinderDetails(this.cylinderId);

  @override
  List<Object?> get props => [cylinderId];
}

class _NewCylinder extends CylinderDetailsEvent {
  const _NewCylinder();
}

class _UpdateCylinderDetails extends CylinderDetailsEvent {
  final Cylinder cylinder;

  const _UpdateCylinderDetails(this.cylinder);

  @override
  List<Object?> get props => [cylinder];
}

class CylinderDetailsBloc extends Bloc<CylinderDetailsEvent, CylinderDetailsState> {
  CylinderDetailsBloc() : super(const CylinderDetailsInitial()) {
    on<CylinderDetailsEvent>((event, emit) async {
      switch (event) {
        case _LoadCylinderDetails():
          await _onLoadCylinderDetails(event, emit);
        case _NewCylinder():
          emit(CylinderDetailsLoaded(Cylinder(), true));
        case _UpdateCylinderDetails():
          await _onUpdateCylinderDetails(event, emit);
      }
    }, transformer: sequential());
  }

  Future<void> _onLoadCylinderDetails(_LoadCylinderDetails event, Emitter<CylinderDetailsState> emit) async {
    try {
      final store = await StorageProvider.store;
      final cylinder = await store.cylinders.getById(event.cylinderId);
      if (cylinder == null) {
        emit(const CylinderDetailsError('Cylinder not found'));
        return;
      }

      emit(CylinderDetailsLoaded(cylinder, false));
    } catch (e) {
      emit(CylinderDetailsError('Failed to load cylinder details: $e'));
    }
  }

  Future<void> _onUpdateCylinderDetails(_UpdateCylinderDetails event, Emitter<CylinderDetailsState> emit) async {
    try {
      final store = await StorageProvider.store;
      await store.cylinders.update(event.cylinder);
      add(_LoadCylinderDetails(event.cylinder.id));
    } catch (e) {
      _log.warning('failed to update cylinder', e);
      emit(CylinderDetailsError('Failed to update cylinder: $e'));
    }
  }
}
