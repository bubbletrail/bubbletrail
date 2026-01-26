import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/details_state.dart';
import '../providers/storage_provider.dart';

final _log = Logger('equipment_details_bloc.dart');

abstract class EquipmentDetailsState extends Equatable with DetailsStateMixin {
  const EquipmentDetailsState();

  @override
  List<Object?> get props => [];
}

class EquipmentDetailsInitial extends EquipmentDetailsState with DetailsInitialMixin {
  const EquipmentDetailsInitial();
}

class EquipmentDetailsClosed extends EquipmentDetailsState with DetailsInitialMixin {
  const EquipmentDetailsClosed();
}

class EquipmentDetailsLoading extends EquipmentDetailsState with DetailsLoadingMixin {
  const EquipmentDetailsLoading();
}

class EquipmentDetailsLoaded extends EquipmentDetailsState with DetailsLoadedMixin {
  final Equipment equipment;
  final bool isNew;

  const EquipmentDetailsLoaded(this.equipment, this.isNew);

  @override
  List<Object?> get props => [equipment, isNew];
}

class EquipmentDetailsError extends EquipmentDetailsState with DetailsErrorMixin {
  @override
  final String errorMessage;

  const EquipmentDetailsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

sealed class EquipmentDetailsEvent extends Equatable {
  const EquipmentDetailsEvent();

  @override
  List<Object?> get props => [];

  const factory EquipmentDetailsEvent.load(String equipmentId) = _Load;
  const factory EquipmentDetailsEvent.newEquipment() = _New;
  const factory EquipmentDetailsEvent.updateAndClose(Equipment equipment) = _UpdateAndClose;
  const factory EquipmentDetailsEvent.deleteAndClosed(String equipmentId) = _DeleteAndClose;
}

class _Load extends EquipmentDetailsEvent {
  final String equipmentId;

  const _Load(this.equipmentId);

  @override
  List<Object?> get props => [equipmentId];
}

class _New extends EquipmentDetailsEvent {
  const _New();
}

class _UpdateAndClose extends EquipmentDetailsEvent {
  final Equipment equipment;

  const _UpdateAndClose(this.equipment);

  @override
  List<Object?> get props => [equipment];
}

class _DeleteAndClose extends EquipmentDetailsEvent {
  final String equipmentId;

  const _DeleteAndClose(this.equipmentId);

  @override
  List<Object?> get props => [equipmentId];
}

class EquipmentDetailsBloc extends Bloc<EquipmentDetailsEvent, EquipmentDetailsState> {
  EquipmentDetailsBloc() : super(const EquipmentDetailsInitial()) {
    on<EquipmentDetailsEvent>((event, emit) async {
      switch (event) {
        case _Load():
          await _onLoadEquipmentDetails(event, emit);
        case _New():
          emit(EquipmentDetailsLoaded(Equipment(), true));
        case _UpdateAndClose():
          await _onUpdateEquipmentDetails(event, emit);
        case _DeleteAndClose():
          await _onDeleteEquipment(event, emit);
      }
    }, transformer: sequential());
  }

  Future<void> _onLoadEquipmentDetails(_Load event, Emitter<EquipmentDetailsState> emit) async {
    try {
      final store = await StorageProvider.store;
      final equipment = await store.equipment.getById(event.equipmentId);
      if (equipment == null) {
        emit(const EquipmentDetailsError('Equipment not found'));
        return;
      }

      emit(EquipmentDetailsLoaded(equipment, false));
    } catch (e) {
      emit(EquipmentDetailsError('Failed to load equipment details: $e'));
    }
  }

  Future<void> _onUpdateEquipmentDetails(_UpdateAndClose event, Emitter<EquipmentDetailsState> emit) async {
    try {
      final store = await StorageProvider.store;
      await store.equipment.update(event.equipment);
      emit(EquipmentDetailsClosed());
    } catch (e) {
      _log.warning('failed to update equipment', e);
      emit(EquipmentDetailsError('Failed to update equipment: $e'));
    }
  }

  Future<void> _onDeleteEquipment(_DeleteAndClose event, Emitter<EquipmentDetailsState> emit) async {
    try {
      final store = await StorageProvider.store;
      await store.equipment.delete(event.equipmentId);
      emit(EquipmentDetailsClosed());
    } catch (e) {
      _log.warning('failed to delete equipment', e);
      emit(EquipmentDetailsError('Failed to delete equipment: $e'));
    }
  }
}
